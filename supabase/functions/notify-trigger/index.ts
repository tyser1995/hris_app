import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// Triggered by pg_cron or webhook to send contract expiry / late alerts
Deno.serve(async (req) => {
  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    )

    const today = new Date()
    const in30Days = new Date(today)
    in30Days.setDate(today.getDate() + 30)

    // Find employees with contracts expiring in 30 days
    const { data: expiringEmployees } = await supabase
      .from('employees')
      .select('id, first_name, last_name, user_id, contract_end')
      .lte('contract_end', in30Days.toISOString().substring(0, 10))
      .gte('contract_end', today.toISOString().substring(0, 10))
      .eq('employment_status', 'active')

    const notifications = (expiringEmployees ?? [])
      .filter((e) => e.user_id)
      .map((e) => ({
        user_id: e.user_id,
        type: 'contract_expiring',
        title: 'Contract Expiring Soon',
        body: `Your employment contract expires on ${e.contract_end}. Please contact HR.`,
        metadata: { employee_id: e.id, contract_end: e.contract_end },
      }))

    if (notifications.length > 0) {
      await supabase.from('notifications').insert(notifications)
    }

    // Find late employees for today
    const todayStr = today.toISOString().substring(0, 10)
    const { data: lateAttendance } = await supabase
      .from('attendance')
      .select('employee_id, late_minutes, employees!employee_id(user_id)')
      .eq('date', todayStr)
      .eq('status', 'late')

    const lateNotifs = (lateAttendance ?? [])
      .filter((a: any) => a.employees?.user_id)
      .map((a: any) => ({
        user_id: a.employees.user_id,
        type: 'late_alert',
        title: 'Late Attendance Recorded',
        body: `You were marked late by ${a.late_minutes} minutes today.`,
        metadata: { employee_id: a.employee_id, late_minutes: a.late_minutes },
      }))

    if (lateNotifs.length > 0) {
      await supabase.from('notifications').insert(lateNotifs)
    }

    return new Response(
      JSON.stringify({
        success: true,
        contract_alerts: notifications.length,
        late_alerts: lateNotifs.length,
      }),
      { headers: { 'Content-Type': 'application/json' } },
    )
  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }), { status: 500 })
  }
})
