import 'package:ess/Ess_App/src/shared/app_widgets.dart';
import 'package:ess/Ess_App/src/shared/bottons.dart';
import 'package:ess/Ess_App/src/shared/input_field.dart';
import 'package:ess/Ess_App/src/shared/top_app_bar.dart';
import 'package:ess/Ess_App/src/styles/app_colors.dart';
import 'package:ess/Ess_App/src/styles/text_theme.dart';
import 'package:ess/Ess_App/src/views/reservation/reserve_board_room/reserve_board_room_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';

class ReserveBoardRoomView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ReserveBoardRoomViewModel>.reactive(
      builder: (viewModelContext, model, child) => Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              GeneralAppBar(
                  title: "Reserve Board Room",
                  onMenuTap: () {
                    Scaffold.of(context).openDrawer();
                  },
                  onNotificationTap: () {}),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                  child: Form(
                    child: Builder(builder: (ctx) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── 1. Choose a room ────────────────────────────
                          _SectionCard(
                            icon: Icons.meeting_room_rounded,
                            title: 'Choose a room',
                            child: Column(
                              children: [
                                for (int i = 0;
                                i < model.boardRoams.length;
                                i++) ...[
                                  if (i > 0) const SizedBox(height: 10),
                                  _RoomTile(
                                    name: model.boardRoams[i],
                                    selected: model.boardRoamSelectedIndex == i,
                                    onTap: () {
                                      model.boardRoamSelectedIndex = i;
                                      model.notifyListeners();
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          // ── 2. Date & time ──────────────────────────────
                          _SectionCard(
                            icon: Icons.event_available_rounded,
                            title: 'Date & time',
                            child: Column(
                              children: [
                                SecondInputField(
                                  label: 'Booking Date',
                                  hint: 'Select Booking Date',
                                  controller: model.bookDate,
                                  inputType: TextInputType.datetime,
                                  onTap: () async {
                                    DateTime? pickedDate = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime(2100));

                                    if (pickedDate != null) {
                                      model.bookDateFormat = pickedDate;
                                      String formattedDate =
                                      DateFormat('yyyy-MM-dd')
                                          .format(pickedDate);
                                      model.bookDate.text = formattedDate;
                                      model.notifyListeners();
                                    }
                                  },
                                  message: 'Please select booking date',
                                  prefixIcon: const Icon(
                                    Icons.calendar_month,
                                    color: AppColors.primary,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: SecondInputField(
                                        label: 'Start Time',
                                        hint: 'Start',
                                        controller: model.fromTime,
                                        inputType: TextInputType.datetime,
                                        onTap: () async {
                                          TimeOfDay? pickedTime =
                                          await showTimePicker(
                                            context: context,
                                            initialTime: TimeOfDay.now(),
                                          );
                                          if (pickedTime != null) {
                                            if (pickedTime.minute == 0) {
                                              model.fromTimeFormat = pickedTime;
                                              model.fromTime.text =
                                              "${pickedTime.hour}";
                                            } else {
                                              model.fromTimeFormat = pickedTime;
                                              model.fromTime.text =
                                              "${pickedTime.hour}:${pickedTime.minute}";
                                            }
                                            model.notifyListeners();
                                          }
                                        },
                                        message: 'Select start time',
                                        prefixIcon: const Icon(
                                          Icons.access_time,
                                          color: AppColors.primary,
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: SecondInputField(
                                        label: 'End Time',
                                        hint: 'End',
                                        controller: model.toTime,
                                        inputType: TextInputType.datetime,
                                        onTap: () async {
                                          TimeOfDay? pickedTime =
                                          await showTimePicker(
                                            context: context,
                                            initialTime: model.fromTimeFormat,
                                          );
                                          if (pickedTime != null) {
                                            if (pickedTime.minute == 0) {
                                              model.toTime.text =
                                              "${pickedTime.hour}";
                                            } else {
                                              model.toTime.text =
                                              "${pickedTime.hour}:${pickedTime.minute}";
                                            }
                                            model.notifyListeners();
                                          }
                                        },
                                        message: 'Select end time',
                                        prefixIcon: const Icon(
                                          Icons.access_time,
                                          color: AppColors.primary,
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          // ── 3. Meeting details ──────────────────────────
                          _SectionCard(
                            icon: Icons.groups_rounded,
                            title: 'Meeting details',
                            child: Column(
                              children: [
                                SecondInputField(
                                  label: 'Employee Code',
                                  hint: 'Enter Employee Code',
                                  controller: model.employeeCode,
                                  inputType: TextInputType.text,
                                  readOnly: true,
                                  message: 'Please enter employee code',
                                  prefixIcon: const Icon(
                                    Icons.badge_outlined,
                                    color: AppColors.primary,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SecondInputField(
                                  label: 'No of People',
                                  hint: 'Enter No of People',
                                  controller: model.nop,
                                  inputType: TextInputType.number,
                                  onTap: () {},
                                  message: 'Please enter no of people',
                                  prefixIcon: const Icon(
                                    Icons.people_outline_rounded,
                                    color: AppColors.primary,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SecondInputField(
                                  label: 'Agenda',
                                  hint: 'Enter Agenda',
                                  controller: model.agenda,
                                  inputType: TextInputType.multiline,
                                  height: 110,
                                  onTap: () {},
                                  message: 'Please enter agenda',
                                ),
                                const SizedBox(height: 16),
                                SecondInputField(
                                  label: 'Reason',
                                  hint: 'Enter Reason',
                                  controller: model.remarks,
                                  inputType: TextInputType.multiline,
                                  height: 110,
                                  onTap: () {},
                                  message: 'Please enter reason',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          MainButton(
                              text: "Reserve",
                              isBusy: model.isBusy,
                              onTap: () {
                                model.apply(ctx);
                              }),
                        ],
                      );
                    }),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      viewModelBuilder: () => ReserveBoardRoomViewModel(),
      onModelReady: (model) => model.init(context),
    );
  }
}

/// White card with an icon + title header; groups one part of the form.
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconTile(icon: icon, size: 34),
              const SizedBox(width: 10),
              Text(title, style: TextStyling.section),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

/// One selectable room ("Board Room 1 - Ground Floor" → title + floor).
class _RoomTile extends StatelessWidget {
  final String name;
  final bool selected;
  final VoidCallback onTap;

  const _RoomTile({
    required this.name,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final parts = name.split(' - ');
    final title = parts.first;
    final subtitle = parts.length > 1 ? parts.sublist(1).join(' - ') : null;
    final isHall = name.toLowerCase().contains('training');
    final radius = BorderRadius.circular(14);

    return Material(
      color: selected ? AppColors.primarySoft : AppColors.surface,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              IconTile(
                icon: isHall
                    ? Icons.co_present_rounded
                    : Icons.meeting_room_outlined,
                size: 38,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyling.bold14),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle, style: TextStyling.caption),
                    ],
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? AppColors.primary : AppColors.grey,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}