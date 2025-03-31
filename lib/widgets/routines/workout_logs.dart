/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/workouts/log.dart';
import 'package:wger/models/workouts/routine.dart';
import 'package:wger/models/workouts/session.dart';
import 'package:wger/theme/theme.dart';
import 'package:wger/widgets/routines/log.dart';

class WorkoutLogs extends StatefulWidget {
  final Routine _routine;

  const WorkoutLogs(this._routine);

  @override
  _WorkoutLogsState createState() => _WorkoutLogsState();
}

class _WorkoutLogsState extends State<WorkoutLogs> {
  final dayController = TextEditingController();

  @override
  void dispose() {
    dayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            AppLocalizations.of(context).labelWorkoutLogs,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            AppLocalizations.of(context).logHelpEntries,
            textAlign: TextAlign.justify,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            AppLocalizations.of(context).logHelpEntriesUnits,
            textAlign: TextAlign.justify,
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: WorkoutLogCalendar(widget._routine),
        ),
      ],
    );
  }
}

/// An event in the workout log calendar
class WorkoutLogEvent {
  final DateTime dateTime;
  final WorkoutSession session;
  final Map<Exercise, List<Log>> exercises;

  const WorkoutLogEvent(this.dateTime, this.session, this.exercises);
}

class WorkoutLogCalendar extends StatefulWidget {
  final Routine _routine;

  const WorkoutLogCalendar(this._routine);

  @override
  _WorkoutLogCalendarState createState() => _WorkoutLogCalendarState();
}

class _WorkoutLogCalendarState extends State<WorkoutLogCalendar> {
  DateTime _focusedDay = clock.now();
  DateTime? _selectedDay;
  late final ValueNotifier<List<WorkoutLogEvent>> _selectedEvents;
  late Map<String, List<WorkoutLogEvent>> _events;

  @override
  void initState() {
    super.initState();

    _events = {};
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    loadEvents();
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  void loadEvents() {
    for (final date in widget._routine.logData.keys) {
      final entry = widget._routine.logData[date]!;
      _events[DateFormatLists.format(date)] = [
        WorkoutLogEvent(date, entry['session'], entry['exercises']),
      ];
    }

    // Add initial selected day to events list
    _selectedEvents.value = _getEventsForDay(_selectedDay!);
  }

  List<WorkoutLogEvent> _getEventsForDay(DateTime day) {
    return _events[DateFormatLists.format(day)] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          locale: Localizations.localeOf(context).languageCode,
          firstDay: clock.now().subtract(const Duration(days: 1000)),
          lastDay: clock.now(),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          calendarFormat: CalendarFormat.month,
          startingDayOfWeek: StartingDayOfWeek.monday,
          calendarStyle: getWgerCalendarStyle(Theme.of(context)),
          eventLoader: _getEventsForDay,
          availableGestures: AvailableGestures.horizontalSwipe,
          availableCalendarFormats: const {CalendarFormat.month: ''},
          onDaySelected: _onDaySelected,
          onPageChanged: (focusedDay) {
            // No need to call `setState()` here
            _focusedDay = focusedDay;
          },
        ),
        const SizedBox(height: 8.0),
        SizedBox(
          child: ValueListenableBuilder<List<WorkoutLogEvent>>(
            valueListenable: _selectedEvents,
            builder: (context, logEvents, _) {
              // At the moment there is only one "event" per day
              return logEvents.isNotEmpty
                  ? DayLogWidget(
                      logEvents.first.dateTime,
                      logEvents.first.exercises,
                      logEvents.first.session,
                      widget._routine,
                    )
                  : Container();
            },
          ),
        ),
      ],
    );
  }
}
