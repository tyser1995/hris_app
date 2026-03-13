import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

interface AttendanceRecord {
  id: string
  employee_id: string
  date: string
  time_in: string
  time_out: string
  schedule_id: string
}

interface ScheduleDetail {
  start_time: string
  end_time: string
  period_label: string
}

Deno.serve(async (req) => {
  try {
    const { attendance_id } = await req.json()

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    )

    // Fetch attendance record
    const { data: att, error: attErr } = await supabase
      .from('attendance')
      .select('*')
      .eq('id', attendance_id)
      .single<AttendanceRecord>()

    if (attErr || !att) {
      return new Response(JSON.stringify({ error: 'Attendance record not found' }), { status: 404 })
    }

    // Fetch schedule details
    const { data: schedDetails } = await supabase
      .from('schedule_details')
      .select('*')
      .eq('schedule_id', att.schedule_id)
      .order('start_time')
      .returns<ScheduleDetail[]>()

    if (!schedDetails || schedDetails.length === 0) {
      return new Response(JSON.stringify({ error: 'Schedule details not found' }), { status: 404 })
    }

    const timeIn = new Date(att.time_in)
    const timeOut = new Date(att.time_out)
    const attendanceDate = att.date

    // For regular or first period of broken shift
    const firstPeriod = schedDetails[0]
    const scheduledStart = new Date(`${attendanceDate}T${firstPeriod.start_time}`)

    // Last period end time
    const lastPeriod = schedDetails[schedDetails.length - 1]
    const scheduledEnd = new Date(`${attendanceDate}T${lastPeriod.end_time}`)

    // Grace period: 15 minutes
    const GRACE_MINUTES = 15
    const OVERTIME_THRESHOLD_MINUTES = 30

    let lateMinutes = 0
    let undertimeMinutes = 0
    let overtimeMinutes = 0
    let status = 'present'

    // Calculate late minutes
    const diffStart = (timeIn.getTime() - scheduledStart.getTime()) / 60000
    if (diffStart > GRACE_MINUTES) {
      lateMinutes = Math.round(diffStart - GRACE_MINUTES)
      status = 'late'
    }

    // Calculate undertime / overtime
    const diffEnd = (timeOut.getTime() - scheduledEnd.getTime()) / 60000
    if (diffEnd < 0) {
      undertimeMinutes = Math.round(Math.abs(diffEnd))
      if (undertimeMinutes > 240) status = 'half_day'
    } else if (diffEnd > OVERTIME_THRESHOLD_MINUTES) {
      overtimeMinutes = Math.round(diffEnd - OVERTIME_THRESHOLD_MINUTES)
      if (status === 'present') status = 'overtime'
    }

    // Update attendance record
    const { error: updateErr } = await supabase
      .from('attendance')
      .update({
        late_minutes: lateMinutes,
        undertime_minutes: undertimeMinutes,
        overtime_minutes: overtimeMinutes,
        status,
        updated_at: new Date().toISOString(),
      })
      .eq('id', attendance_id)

    if (updateErr) {
      return new Response(JSON.stringify({ error: updateErr.message }), { status: 500 })
    }

    return new Response(
      JSON.stringify({
        success: true,
        late_minutes: lateMinutes,
        undertime_minutes: undertimeMinutes,
        overtime_minutes: overtimeMinutes,
        status,
      }),
      { headers: { 'Content-Type': 'application/json' } },
    )
  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }), { status: 500 })
  }
})
