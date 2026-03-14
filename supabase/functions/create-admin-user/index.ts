import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) return json({ error: "Missing authorization header" }, 401);

    const supabaseUrl    = Deno.env.get("SUPABASE_URL")!;
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const siteUrl        = Deno.env.get("SITE_URL") ?? supabaseUrl;

    const adminClient = createClient(supabaseUrl, serviceRoleKey);
    const hrisClient  = createClient(supabaseUrl, serviceRoleKey, {
      db: { schema: "hris" },
    });

    // ── Verify caller is super_admin ─────────────────────────────────────────
    const token = authHeader.replace("Bearer ", "");
    const { data: { user: caller }, error: callerError } =
      await adminClient.auth.getUser(token);

    if (callerError || !caller) return json({ error: "Unauthorized" }, 401);

    const { data: roleRow } = await hrisClient
      .from("user_roles")
      .select("role")
      .eq("user_id", caller.id)
      .single();

    if (roleRow?.role !== "super_admin") {
      return json({ error: "Only super_admin can create admin accounts" }, 403);
    }

    // ── Parse body ───────────────────────────────────────────────────────────
    const { orgName, email, autoConfirm, password } = await req.json();

    if (!orgName || !email) {
      return json({ error: "orgName and email are required" }, 400);
    }
    if (autoConfirm && !password) {
      return json({ error: "password is required when autoConfirm is true" }, 400);
    }

    // ── 1. Create the organization ───────────────────────────────────────────
    const { data: org, error: orgError } = await hrisClient
      .from("organizations")
      .insert({ name: orgName, system_title: `${orgName} HRIS` })
      .select()
      .single();

    if (orgError) return json({ error: orgError.message }, 400);

    // ── 2. Create or invite the admin user ───────────────────────────────────
    let userId: string;
    let message: string;

    if (autoConfirm) {
      // Immediate account — no email confirmation required
      const { data, error } = await adminClient.auth.admin.createUser({
        email,
        password,
        email_confirm: true,
      });
      if (error) {
        await hrisClient.from("organizations").delete().eq("id", org.id);
        return json({ error: error.message }, 400);
      }
      userId  = data.user.id;
      message = `Admin account for ${email} created. They can log in immediately.`;
    } else {
      // Invite flow — admin sets their own password via email link
      const { data: inviteData, error: inviteError } =
        await adminClient.auth.admin.inviteUserByEmail(email, {
          redirectTo: siteUrl,
        });
      if (inviteError) {
        await hrisClient.from("organizations").delete().eq("id", org.id);
        return json({ error: inviteError.message }, 400);
      }
      userId  = inviteData.user.id;
      message = `Invitation email sent to ${email}.`;
    }

    // ── 3. Assign admin role + link to org ───────────────────────────────────
    const { error: roleError } = await hrisClient
      .from("user_roles")
      .insert({
        user_id: userId,
        role: "admin",
        organization_id: org.id,
      });

    if (roleError) {
      await adminClient.auth.admin.deleteUser(userId);
      await hrisClient.from("organizations").delete().eq("id", org.id);
      return json({ error: roleError.message }, 400);
    }

    return json({
      organization: { id: org.id, name: org.name, systemTitle: org.system_title },
      user: { id: userId, email },
      autoConfirm: autoConfirm ?? false,
      message,
    });
  } catch (err) {
    return json({ error: String(err) }, 500);
  }
});

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
