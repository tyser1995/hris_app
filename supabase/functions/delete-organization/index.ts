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
      return json({ error: "Only super_admin can delete organizations" }, 403);
    }

    // ── Parse body ───────────────────────────────────────────────────────────
    const { organizationId } = await req.json();

    if (!organizationId) {
      return json({ error: "organizationId is required" }, 400);
    }

    // ── 1. Find all admin users for this org ─────────────────────────────────
    const { data: adminRoles, error: rolesError } = await hrisClient
      .from("user_roles")
      .select("user_id")
      .eq("organization_id", organizationId)
      .eq("role", "admin");

    if (rolesError) return json({ error: rolesError.message }, 400);

    // ── 2. Delete the organization (cascades user_roles via FK) ──────────────
    const { error: orgError } = await hrisClient
      .from("organizations")
      .delete()
      .eq("id", organizationId);

    if (orgError) return json({ error: orgError.message }, 400);

    // ── 3. Delete admin auth users ───────────────────────────────────────────
    const deletedUsers: string[] = [];
    const failedUsers: string[] = [];

    for (const row of adminRoles ?? []) {
      const { error: deleteError } =
        await adminClient.auth.admin.deleteUser(row.user_id);
      if (deleteError) {
        failedUsers.push(row.user_id);
      } else {
        deletedUsers.push(row.user_id);
      }
    }

    return json({
      success: true,
      organizationId,
      deletedAdminUsers: deletedUsers,
      ...(failedUsers.length > 0 && { warningFailedUserDeletes: failedUsers }),
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
