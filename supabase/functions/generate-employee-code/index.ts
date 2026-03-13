/**
 * generate-employee-code
 *
 * Atomically increments `company_settings.employee_code_sequence` and returns
 * the next generated employee code by delegating to the `next_employee_code()`
 * Postgres function (migration 011).
 *
 * The DB function holds a row-level lock for the duration of the UPDATE, so
 * concurrent invocations are safely serialised — no duplicate codes.
 *
 * Response shape:
 *   200  { "code": "26-E001-03" }
 *   400  { "error": "<db error message>" }
 *   500  { "error": "<unexpected error>" }
 */

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

Deno.serve(async (_req) => {
  const headers = { 'Content-Type': 'application/json' }

  try {
    // Use service role so the security-definer function can UPDATE without
    // being blocked by the authenticated-only RLS write policy.
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    )

    const { data, error } = await supabase.rpc('next_employee_code')

    if (error) {
      console.error('[generate-employee-code] DB error:', error.message)
      return new Response(
        JSON.stringify({ error: error.message }),
        { status: 400, headers },
      )
    }

    console.log('[generate-employee-code] Generated code:', data)
    return new Response(
      JSON.stringify({ code: data as string }),
      { status: 200, headers },
    )
  } catch (err) {
    console.error('[generate-employee-code] Unexpected error:', err)
    return new Response(
      JSON.stringify({ error: String(err) }),
      { status: 500, headers },
    )
  }
})
