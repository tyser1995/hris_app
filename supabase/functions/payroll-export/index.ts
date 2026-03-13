import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

interface PayrollExportPayload {
  year: number
  month: number
  department_id?: string
}

Deno.serve(async (req) => {
  try {
    const payload: PayrollExportPayload = await req.json()
    const { year, month, department_id } = payload

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    )

    const startDate = `${year}-${String(month).padStart(2, '0')}-01`
    const endDate = new Date(year, month, 0).toISOString().substring(0, 10)

    let employeeQuery = supabase
      .from('employees')
      .select('id, employee_code, first_name, last_name, department_id, departments(name)')
      .eq('employment_status', 'active')

    if (department_id) {
      employeeQuery = employeeQuery.eq('department_id', department_id)
    }

    const { data: employees } = await employeeQuery

    const results = await Promise.all(
      (employees ?? []).map(async (emp: any) => {
        // Get attendance summary for the month
        const { data: attendance } = await supabase
          .from('attendance')
          .select('status, late_minutes, undertime_minutes, overtime_minutes')
          .eq('employee_id', emp.id)
          .gte('date', startDate)
          .lte('date', endDate)

        const records = attendance ?? []
        const daysWorked = records.filter((r) =>
          ['present', 'late', 'overtime', 'half_day'].includes(r.status),
        ).length
        const totalLateMinutes = records.reduce((s, r) => s + (r.late_minutes ?? 0), 0)
        const totalOvertimeMinutes = records.reduce((s, r) => s + (r.overtime_minutes ?? 0), 0)
        const absences = records.filter((r) => r.status === 'absent').length

        // Get approved leave days
        const { data: leaves } = await supabase
          .from('leave_requests')
          .select('days_requested')
          .eq('employee_id', emp.id)
          .eq('status', 'approved')
          .gte('start_date', startDate)
          .lte('end_date', endDate)

        const leaveDays = (leaves ?? []).reduce((s, l) => s + (l.days_requested ?? 0), 0)

        return {
          employee_id: emp.id,
          employee_code: emp.employee_code,
          first_name: emp.first_name,
          last_name: emp.last_name,
          department: emp.departments?.name ?? '',
          days_worked: daysWorked,
          total_late_minutes: totalLateMinutes,
          overtime_hours: (totalOvertimeMinutes / 60).toFixed(2),
          absences,
          leave_days: leaveDays,
        }
      }),
    )

    return new Response(JSON.stringify({ success: true, data: results, period: { year, month } }), {
      headers: { 'Content-Type': 'application/json' },
    })
  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }), { status: 500 })
  }
})
