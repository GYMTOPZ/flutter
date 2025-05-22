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

import 'package:flutter/material.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/workouts/slot_entry.dart';

class RepetitionsInputWidget extends StatelessWidget {
  final _repetitionsController = TextEditingController();
  final SlotEntry _setting;
  final bool _detailed;

  RepetitionsInputWidget(this._setting, this._detailed);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: _detailed ? AppLocalizations.of(context).repetitions : '',
        errorMaxLines: 2,
      ),
      controller: _repetitionsController,
      keyboardType: TextInputType.number,
      validator: (value) {
        try {
          if (value != '') {
            double.parse(value!);
          }
        } catch (error) {
          return AppLocalizations.of(context).enterValidNumber;
        }
        return null;
      },
      onChanged: (newValue) {
        if (newValue != '') {
          try {
            // _setting.reps = int.parse(newValue);
          } catch (e) {}
        }
      },
    );
  }
}
