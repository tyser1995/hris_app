import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
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

    // Service-role client — used for auth.admin operations and DB writes
    const adminClient = createClient(supabaseUrl, serviceRoleKey);
    const hrisClient  = createClient(supabaseUrl, serviceRoleKey, {
      db: { schema: "hris" },
    });

    // ── Verify caller: extract JWT and resolve the user ──────────────────────
    // auth.getUser(token) validates the JWT server-side without a stored session.
    const token = authHeader.replace("Bearer ", "");
    const { data: { user: caller }, error: callerError } =
      await adminClient.auth.getUser(token);

    if (callerError || !caller) return json({ error: "Unauthorized" }, 401);

    // ── Require super_admin ──────────────────────────────────────────────────
    const { data: roleRow } = await hrisClient
      .from("user_roles")
      .select("role")
      .eq("user_id", caller.id)
      .single();

    if (roleRow?.role !== "super_admin") {
      return json({ error: "Only super_admin can create user accounts" }, 403);
    }

    // ── Parse body ───────────────────────────────────────────────────────────
    const { email, password, autoConfirm, role, organizationId } =
      await req.json();

    if (!email || !role || !organizationId) {
      return json({ error: "email, role, and organizationId are required" }, 400);
    }
    if (autoConfirm && !password) {
      return json({ error: "password is required when autoConfirm is true" }, 400);
    }

    // ── Create or invite the user ────────────────────────────────────────────
    let userId: string;

    if (autoConfirm) {
      const { data, error } = await adminClient.auth.admin.createUser({
        email,
        password,
        email_confirm: true,
      });
      if (error) return json({ error: error.message }, 400);
      userId = data.user.id;
    } else {
      const { data, error } = await adminClient.auth.admin.inviteUserByEmail(
        email,
        { redirectTo: siteUrl },
      );
      if (error) return json({ error: error.message }, 400);
      userId = data.user.id;
    }

    // ── Assign role + organization ───────────────────────────────────────────
    const { error: roleError } = await hrisClient
      .from("user_roles")
      .insert({ user_id: userId, role, organization_id: organizationId });

    if (roleError) {
      await adminClient.auth.admin.deleteUser(userId);
      return json({ error: roleError.message }, 400);
    }

    return json({
      user: { id: userId, email, role },
      autoConfirm,
      message: autoConfirm
        ? `User ${email} created successfully.`
        : `Invitation email sent to ${email}.`,
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
