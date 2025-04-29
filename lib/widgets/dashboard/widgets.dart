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

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_icons/flutter_svg_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wger/helpers/misc.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/models/workouts/routine.dart';
import 'package:wger/providers/body_weight.dart';
import 'package:wger/providers/measurement.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/providers/routines.dart';
import 'package:wger/providers/user.dart';
import 'package:wger/screens/form_screen.dart';
import 'package:wger/screens/gym_mode.dart';
import 'package:wger/screens/log_meals_screen.dart';
import 'package:wger/screens/measurement_categories_screen.dart';
import 'package:wger/screens/nutritional_plan_screen.dart';
import 'package:wger/screens/routine_screen.dart';
import 'package:wger/screens/weight_screen.dart';
import 'package:wger/theme/theme.dart';
import 'package:wger/widgets/core/core.dart';
import 'package:wger/widgets/measurements/categories_card.dart';
import 'package:wger/widgets/measurements/charts.dart';
import 'package:wger/widgets/measurements/forms.dart';
import 'package:wger/widgets/measurements/helpers.dart';
import 'package:wger/widgets/nutrition/charts.dart';
import 'package:wger/widgets/nutrition/forms.dart';
import 'package:wger/widgets/routines/forms/routine.dart';
import 'package:wger/widgets/weight/forms.dart';

class DashboardNutritionWidget extends StatefulWidget {
  const DashboardNutritionWidget();

  @override
  _DashboardNutritionWidgetState createState() => _DashboardNutritionWidgetState();
}

class _DashboardNutritionWidgetState extends State<DashboardNutritionWidget> {
  NutritionalPlan? _plan;
  bool _hasContent = false;

  @override
  void initState() {
    super.initState();
    _plan = Provider.of<NutritionPlansProvider>(context, listen: false).currentPlan;
    _hasContent = _plan != null;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(
              _hasContent ? _plan!.description : AppLocalizations.of(context).nutritionalPlan,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            subtitle: Text(
              _hasContent
                  ? DateFormat.yMd(Localizations.localeOf(context).languageCode)
                      .format(_plan!.creationDate)
                  : '',
            ),
            leading: Icon(
              Icons.restaurant,
              color: Theme.of(context).textTheme.headlineSmall!.color,
            ),
          ),
          if (_hasContent)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
                child: FlNutritionalPlanGoalWidget(nutritionalPlan: _plan!),
              ),
            )
          else
            NothingFound(
              AppLocalizations.of(context).noNutritionalPlans,
              AppLocalizations.of(context).newNutritionalPlan,
              PlanForm(),
            ),
          if (_hasContent)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: Text(AppLocalizations.of(context).goToDetailPage),
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      NutritionalPlanScreen.routeName,
                      arguments: _plan,
                    );
                  },
                ),
                Expanded(child: Container()),
                IconButton(
                  icon: const SvgIcon(
                    icon: SvgIconData('assets/icons/ingredient-diary.svg'),
                  ),
                  tooltip: AppLocalizations.of(context).logIngredient,
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      FormScreen.routeName,
                      arguments: FormScreenArguments(
                        AppLocalizations.of(context).logIngredient,
                        IngredientLogForm(_plan!),
                        hasListView: true,
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const SvgIcon(
                    icon: SvgIconData('assets/icons/meal-diary.svg'),
                  ),
                  tooltip: AppLocalizations.of(context).logMeal,
                  onPressed: () {
                    Navigator.of(context).pushNamed(LogMealsScreen.routeName, arguments: _plan);
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class DashboardWeightWidget extends StatelessWidget {
  const DashboardWeightWidget();

  @override
  Widget build(BuildContext context) {
    final profile = context.read<UserProvider>().profile;
    final weightProvider = context.read<BodyWeightProvider>();

    final (entriesAll, entries7dAvg) = sensibleRange(
      weightProvider.items.map((e) => MeasurementChartEntry(e.weight, e.date)).toList(),
    );

    return Consumer<BodyWeightProvider>(
      builder: (context, workoutProvider, child) => Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                AppLocalizations.of(context).weight,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              leading: FaIcon(
                FontAwesomeIcons.weightScale,
                color: Theme.of(context).textTheme.headlineSmall!.color,
              ),
            ),
            Column(
              children: [
                if (weightProvider.items.isNotEmpty)
                  Column(
                    children: [
                      SizedBox(
                        height: 200,
                        child: MeasurementChartWidgetFl(
                          entriesAll,
                          weightUnit(profile!.isMetric, context),
                          avgs: entries7dAvg,
                        ),
                      ),
                      if (entries7dAvg.isNotEmpty)
                        MeasurementOverallChangeWidget(
                          entries7dAvg.first,
                          entries7dAvg.last,
                          weightUnit(profile.isMetric, context),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            child: Text(
                              AppLocalizations.of(context).goToDetailPage,
                            ),
                            onPressed: () {
                              Navigator.of(context).pushNamed(WeightScreen.routeName);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                FormScreen.routeName,
                                arguments: FormScreenArguments(
                                  AppLocalizations.of(context).newEntry,
                                  WeightForm(weightProvider
                                      .getNewestEntry()
                                      ?.copyWith(id: null, date: DateTime.now())),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  )
                else
                  NothingFound(
                    AppLocalizations.of(context).noWeightEntries,
                    AppLocalizations.of(context).newEntry,
                    WeightForm(),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardMeasurementWidget extends StatefulWidget {
  const DashboardMeasurementWidget();

  @override
  _DashboardMeasurementWidgetState createState() => _DashboardMeasurementWidgetState();
}

class _DashboardMeasurementWidgetState extends State<DashboardMeasurementWidget> {
  int _current = 0;
  final _controller = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MeasurementProvider>(context, listen: false);

    final items =
        provider.categories.map<Widget>((item) => CategoriesCard(item, elevation: 0)).toList();
    if (items.isNotEmpty) {
      items.add(
        NothingFound(
          AppLocalizations.of(context).moreMeasurementEntries,
          AppLocalizations.of(context).newEntry,
          MeasurementCategoryForm(),
        ),
      );
    }
    return Consumer<MeasurementProvider>(
      builder: (context, workoutProvider, child) => Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                AppLocalizations.of(context).measurements,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              leading: FaIcon(
                FontAwesomeIcons.chartLine,
                color: Theme.of(context).textTheme.headlineSmall!.color,
              ),
              // TODO: this icon feels out of place and inconsistent with all
              // other dashboard widgets.
              // maybe we should just add a "Go to all" at the bottom of the widget
              trailing: IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () => Navigator.pushNamed(
                  context,
                  MeasurementCategoriesScreen.routeName,
                ),
              ),
            ),
            Column(
              children: [
                if (items.isNotEmpty)
                  Column(
                    children: [
                      CarouselSlider(
                        items: items,
                        carouselController: _controller,
                        options: CarouselOptions(
                          autoPlay: false,
                          enlargeCenterPage: false,
                          viewportFraction: 1,
                          enableInfiniteScroll: false,
                          aspectRatio: 1.1,
                          onPageChanged: (index, reason) {
                            setState(() {
                              _current = index;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: items.asMap().entries.map((entry) {
                            return GestureDetector(
                              onTap: () => _controller.animateToPage(entry.key),
                              child: Container(
                                width: 12.0,
                                height: 12.0,
                                margin: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                  horizontal: 4.0,
                                ),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      Theme.of(context).textTheme.headlineSmall!.color!.withOpacity(
                                            _current == entry.key ? 0.9 : 0.4,
                                          ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  )
                else
                  NothingFound(
                    AppLocalizations.of(context).noMeasurementEntries,
                    AppLocalizations.of(context).newEntry,
                    MeasurementCategoryForm(),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardWorkoutWidget extends StatefulWidget {
  const DashboardWorkoutWidget();

  @override
  _DashboardWorkoutWidgetState createState() => _DashboardWorkoutWidgetState();
}

class _DashboardWorkoutWidgetState extends State<DashboardWorkoutWidget> {
  var _showDetail = false;
  bool _hasContent = false;

  Routine? _routine;

  @override
  void initState() {
    super.initState();
    _routine = context.read<RoutinesProvider>().activeRoutine;
    _hasContent = _routine != null;
  }

  List<Widget> getContent() {
    final List<Widget> out = [];

    if (!_hasContent) {
      return out;
    }

    for (final dayData in _routine!.dayDataCurrentIteration) {
      if (dayData.day == null) {
        continue;
      }

      out.add(SizedBox(
        width: double.infinity,
        child: Row(
          children: [
            if (dayData.date.isSameDayAs(DateTime.now())) const Icon(Icons.today),
            Expanded(
              child: Text(
                dayData.day == null || dayData.day!.isRest
                    ? AppLocalizations.of(context).restDay
                    : dayData.day!.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              child: MutedText(
                dayData.day != null ? dayData.day!.description : '',
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (dayData.day == null || dayData.day!.isRest)
              const Icon(Icons.hotel)
            else
              IconButton(
                icon: const Icon(Icons.play_arrow),
                color: wgerPrimaryButtonColor,
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    GymModeScreen.routeName,
                    arguments: GymModeArguments(_routine!.id!, dayData.day!.id!, dayData.iteration),
                  );
                },
              ),
          ],
        ),
      ));

      for (final slotData in dayData.slots) {
        out.add(SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...slotData.setConfigs.map(
                (s) => _showDetail
                    ? Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.exercise
                                  .getTranslation(Localizations.localeOf(context).languageCode)
                                  .name),
                              const SizedBox(width: 10),
                              Expanded(
                                child: MutedText(s.textRepr, overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                        ],
                      )
                    : Container(),
              ),
            ],
          ),
        ));
      }
      out.add(const Divider());
    }

    // if (_routine!.fitInWeek) {
    //   out.add(Row(
    //     children: [
    //       Expanded(
    //         child: Text(
    //           AppLocalizations.of(context).tillEndOfWeek,
    //           style: const TextStyle(fontWeight: FontWeight.bold),
    //           overflow: TextOverflow.ellipsis,
    //         ),
    //       ),
    //       const Icon(Icons.hotel),
    //     ],
    //   ));
    //   out.add(const Divider());
    // }

    return out;
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMd(Localizations.localeOf(context).languageCode);

    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(
              _hasContent ? _routine!.name : AppLocalizations.of(context).labelWorkoutPlan,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            subtitle: Text(
              _hasContent
                  ? '${dateFormat.format(_routine!.start)} - ${dateFormat.format(_routine!.end)}'
                  : '',
            ),
            leading: Icon(
              Icons.fitness_center,
              color: Theme.of(context).textTheme.headlineSmall!.color,
            ),
            trailing: _hasContent
                ? Tooltip(
                    message: AppLocalizations.of(context).toggleDetails,
                    child: _showDetail ? const Icon(Icons.info) : const Icon(Icons.info_outline),
                  )
                : const SizedBox(),
            onTap: () {
              setState(() {
                _showDetail = !_showDetail;
              });
            },
          ),
          if (_hasContent)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(children: [...getContent()]),
            )
          else
            NothingFound(
              AppLocalizations.of(context).noRoutines,
              AppLocalizations.of(context).newRoutine,
              RoutineForm(Routine.empty()),
            ),
          if (_hasContent)
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton(
                  child: Text(AppLocalizations.of(context).goToDetailPage),
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      RoutineScreen.routeName,
                      arguments: _routine!.id,
                    );
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class NothingFound extends StatelessWidget {
  final String _title;
  final String _titleForm;
  final Widget _form;

  const NothingFound(this._title, this._titleForm, this._form);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_title),
          IconButton(
            iconSize: 30,
            icon: const Icon(Icons.add_box, color: wgerPrimaryButtonColor),
            onPressed: () {
              Navigator.pushNamed(
                context,
                FormScreen.routeName,
                arguments: FormScreenArguments(
                  _titleForm,
                  hasListView: true,
                  _form,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
