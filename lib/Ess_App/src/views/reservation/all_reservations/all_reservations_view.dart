import 'package:ess/Ess_App/src/models/api_response_models/all_reservation.dart';
import 'package:ess/Ess_App/src/shared/app_widgets.dart';
import 'package:ess/Ess_App/src/shared/loading_indicator.dart';
import 'package:ess/Ess_App/src/shared/top_app_bar.dart';
import 'package:ess/Ess_App/src/styles/app_colors.dart';
import 'package:ess/Ess_App/src/styles/text_theme.dart';
import 'package:ess/Ess_App/src/views/reservation/all_reservations/all_reservations_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';

class AllReservationsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AllReservationsViewModel>.reactive(
      builder: (viewModelContext, model, child) => Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              GeneralAppBar(
                  title: "All Reservations",
                  onMenuTap: () {
                    Scaffold.of(context).openDrawer();
                  },
                  onNotificationTap: () {}),
              Expanded(
                child: model.isBusy
                    ? const Center(child: LoadingIndicator())
                    : model.reservationData.isEmpty
                    ? const Center(
                  child: EmptyState(
                    title: 'No reservations',
                    subtitle: 'Boardroom bookings will appear here.',
                    icon: Icons.meeting_room_outlined,
                  ),
                )
                    : ListView.builder(
                  // +1 for the small count header at the top
                  itemCount: model.reservationData.length + 1,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding:
                        const EdgeInsets.fromLTRB(2, 4, 2, 12),
                        child: Text(
                          '${model.reservationData.length} reservation'
                              '${model.reservationData.length == 1 ? '' : 's'}',
                          style: TextStyling.label,
                        ),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ReservationCard(
                        data: model.reservationData[index - 1],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      viewModelBuilder: () => AllReservationsViewModel(),
      onModelReady: (model) => model.init(context),
    );
  }
}

String _clean(String? v) {
  if (v == null) return '';
  final t = v.trim();
  return (t.isEmpty || t.toLowerCase() == 'null') ? '' : t;
}

/// Same words as StatusChip.fromText, plus a few booking-specific ones.
StatusTone _toneFor(String status) {
  final s = status.toLowerCase();
  if (s.contains('book') ||
      s.contains('confirm') ||
      s.contains('reserv') ||
      s.contains('approv')) {
    return StatusTone.success;
  }
  if (s.contains('cancel') || s.contains('reject') || s.contains('declin')) {
    return StatusTone.danger;
  }
  if (s.contains('pend') || s.contains('wait')) {
    return StatusTone.warning;
  }
  return StatusTone.neutral;
}

class _ReservationCard extends StatelessWidget {
  final ReservationDatalist data;

  const _ReservationCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final room = _clean(data.boardRoom);
    final time = _clean(data.reserveTime);
    final status = _clean(data.eventStatus);
    final bookedBy = _clean(data.bookBy);
    final people = _clean(data.noOfPeople);
    final agenda = _clean(data.agenda);
    final remarks = _clean(data.remarks);

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: date badge · room + time · status ──────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DateBadge(raw: _clean(data.reserveDate)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.isEmpty ? 'Board room' : room,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyling.bold16,
                    ),
                    if (time.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.schedule_rounded,
                              size: 15, color: AppColors.darkGrey),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              time,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyling.caption,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (status.isNotEmpty) ...[
                const SizedBox(width: 8),
                StatusChip(label: status, tone: _toneFor(status)),
              ],
            ],
          ),

          // ── Booked by / people strip ───────────────────────────────────
          if (bookedBy.isNotEmpty || people.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  if (bookedBy.isNotEmpty)
                    Expanded(
                      child: _MiniInfo(
                        icon: Icons.person_outline_rounded,
                        label: 'Booked by',
                        value: bookedBy,
                      ),
                    ),
                  if (bookedBy.isNotEmpty && people.isNotEmpty)
                    Container(
                      width: 1,
                      height: 30,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      color: AppColors.border,
                    ),
                  if (people.isNotEmpty)
                    SizedBox(
                      width: 80,
                      child: _MiniInfo(
                        icon: Icons.groups_outlined,
                        label: 'People',
                        value: people,
                      ),
                    ),
                ],
              ),
            ),
          ],

          // ── Agenda / remarks as readable text blocks ───────────────────
          if (agenda.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text('Agenda', style: TextStyling.caption),
            const SizedBox(height: 3),
            Text(
              agenda,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyling.body.copyWith(color: AppColors.black),
            ),
          ],
          if (remarks.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Remarks', style: TextStyling.caption),
            const SizedBox(height: 3),
            Text(
              remarks,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyling.body,
            ),
          ],
        ],
      ),
    );
  }
}

/// Day number + month in a tinted square. Falls back to a calendar icon if
/// the date text can't be parsed (the original text is shown under it).
class _DateBadge extends StatelessWidget {
  final String raw;

  const _DateBadge({required this.raw});

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(raw);

    return Container(
      width: 56,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: date != null
          ? Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            DateFormat('MMM').format(date).toUpperCase(),
            style: TextStyling.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
          Text(
            DateFormat('d').format(date),
            style: TextStyling.extraBold22
                .copyWith(color: AppColors.primary, height: 1.15),
          ),
          Text(
            DateFormat('E').format(date),
            style: TextStyling.caption.copyWith(fontSize: 11),
          ),
        ],
      )
          : Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.event_rounded,
              size: 24, color: AppColors.primary),
          if (raw.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              raw,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyling.caption.copyWith(fontSize: 10),
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MiniInfo({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyling.caption.copyWith(fontSize: 11)),
              const SizedBox(height: 1),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyling.bold14,
              ),
            ],
          ),
        ),
      ],
    );
  }
}