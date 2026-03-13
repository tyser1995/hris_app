import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

interface ApproveLeavePayload {
  leave_id: string
  action: 'approve' | 'reject'
  approver_id: string
  remarks?: string
  level: 'supervisor' | 'hr'
}

Deno.serve(async (req) => {
  try {
    const payload: ApproveLeavePayload = await req.json()
    const { leave_id, action, approver_id, remarks, level } = payload

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    )

    // Fetch leave request
    const { data: leave, error: leaveErr } = await supabase
      .from('leave_requests')
      .select('*, employees!employee_id(user_id, first_name, last_name)')
      .eq('id', leave_id)
      .single()

    if (leaveErr || !leave) {
      return new Response(JSON.stringify({ error: 'Leave request not found' }), { status: 404 })
    }

    let newStatus: string
    let updateData: Record<string, unknown>
    const now = new Date().toISOString()

    if (action === 'reject') {
      newStatus = 'rejected'
      updateData =
        level === 'supervisor'
          ? { status: newStatus, supervisor_action_at: now, supervisor_remarks: remarks }
          : { status: newStatus, hr_action_at: now, hr_remarks: remarks, hr_approver_id: approver_id }
    } else if (level === 'supervisor') {
      newStatus = 'pending_hr'
      updateData = {
        status: newStatus,
        supervisor_id: approver_id,
        supervisor_action_at: now,
        supervisor_remarks: remarks,
      }
    } else {
      // HR final approval
      newStatus = 'approved'
      updateData = {
        status: newStatus,
        hr_approver_id: approver_id,
        hr_action_at: now,
        hr_remarks: remarks,
      }

      // Deduct from leave balance
      const year = new Date(leave.start_date).getFullYear()
      await supabase
        .from('leave_balances')
        .upsert(
          {
            employee_id: leave.employee_id,
            year,
            leave_type: leave.leave_type,
            total_days: leave.days_requested,
            used_days: leave.days_requested,
          },
          { onConflict: 'employee_id,year,leave_type', ignoreDuplicates: false },
        )

      // Increment used_days
      await supabase.rpc('increment_leave_used', {
        p_employee_id: leave.employee_id,
        p_year: year,
        p_leave_type: leave.leave_type,
        p_days: leave.days_requested,
      })
    }

    // Update leave request
    await supabase.from('leave_requests').update(updateData).eq('id', leave_id)

    // Send notification to employee
    const notifType = action === 'approve' ? 'leave_approved' : 'leave_rejected'
    const notifTitle = action === 'approve' ? 'Leave Request Approved' : 'Leave Request Rejected'
    const notifBody =
      action === 'approve'
        ? `Your ${leave.leave_type} leave request has been approved.`
        : `Your ${leave.leave_type} leave request was rejected. Remarks: ${remarks ?? 'N/A'}`

    if (leave.employees?.user_id) {
      await supabase.from('notifications').insert({
        user_id: leave.employees.user_id,
        type: notifType,
        title: notifTitle,
        body: notifBody,
        metadata: { leave_id, action, level },
      })
    }

    return new Response(JSON.stringify({ success: true, new_status: newStatus }), {
      headers: { 'Content-Type': 'application/json' },
    })
  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }), { status: 500 })
  }
})
