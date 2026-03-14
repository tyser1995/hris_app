import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const ALLOWED_ROLES = ["hr_staff", "department_head", "supervisor", "employee"];

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

    // ── Verify caller ────────────────────────────────────────────────────────
    const token = authHeader.replace("Bearer ", "");
    const { data: { user: caller }, error: callerError } =
      await adminClient.auth.getUser(token);

    if (callerError || !caller) return json({ error: "Unauthorized" }, 401);

    const { data: callerRoleRow } = await hrisClient
      .from("user_roles")
      .select("role, organization_id")
      .eq("user_id", caller.id)
      .single();

    if (!callerRoleRow || !["admin", "hr_staff"].includes(callerRoleRow.role)) {
      return json({ error: "Only admin or hr_staff can invite users" }, 403);
    }

    const organizationId: string = callerRoleRow.organization_id;
    if (!organizationId) {
      return json({ error: "Caller has no organization assigned" }, 400);
    }

    // ── Parse body ───────────────────────────────────────────────────────────
    const { email, role } = await req.json();

    if (!email || !role) {
      return json({ error: "email and role are required" }, 400);
    }
    if (!ALLOWED_ROLES.includes(role)) {
      return json({ error: `Invalid role. Allowed: ${ALLOWED_ROLES.join(", ")}` }, 400);
    }

    // ── Check for duplicate ──────────────────────────────────────────────────
    const { data: existing } = await hrisClient
      .from("user_roles")
      .select("user_id")
      .eq("organization_id", organizationId)
      .limit(1);

    // ── Invite via email ─────────────────────────────────────────────────────
    const { data: inviteData, error: inviteError } =
      await adminClient.auth.admin.inviteUserByEmail(email, {
        redirectTo: siteUrl,
      });

    if (inviteError) return json({ error: inviteError.message }, 400);

    // ── Assign role + org ────────────────────────────────────────────────────
    const { error: roleError } = await hrisClient
      .from("user_roles")
      .insert({
        user_id: inviteData.user.id,
        role,
        organization_id: organizationId,
      });

    if (roleError) {
      await adminClient.auth.admin.deleteUser(inviteData.user.id);
      return json({ error: roleError.message }, 400);
    }

    return json({
      user: { id: inviteData.user.id, email: inviteData.user.email, role },
      message: `Invitation email sent to ${email}`,
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
