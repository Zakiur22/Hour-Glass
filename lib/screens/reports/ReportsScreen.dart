// Copyright 2020 Kenton Hamaluik
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:hourglass/blocs/projects/bloc.dart';
import 'package:hourglass/blocs/settings/settings_bloc.dart';
import 'package:hourglass/components/DateRangeTile.dart';
import 'package:hourglass/components/ProjectTile.dart';
import 'package:hourglass/l10n.dart';
import 'package:hourglass/models/project.dart';
import 'package:hourglass/screens/reports/components/ProjectBreakdown.dart';
import 'package:hourglass/screens/reports/components/TimeTable.dart';
import 'package:hourglass/screens/reports/components/WeekdayAverages.dart';
import 'package:hourglass/screens/reports/components/WeeklyTotals.dart';
import 'package:hourglass/screens/reports/components/WeeklyProductivityDashboard.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  List<Project?> selectedProjects = [];

  @override
  void initState() {
    super.initState();
    final projects = BlocProvider.of<ProjectsBloc>(context);
    selectedProjects = <Project?>[null]
        .followedBy(projects.state.projects
            .where((p) => !p.archived)
            .map((p) => Project.clone(p)))
        .toList();

    final settings = BlocProvider.of<SettingsBloc>(context);
    _startDate = settings.getFilterStartDate();
  }

  @override
  Widget build(BuildContext context) {
    final projectsBloc = BlocProvider.of<ProjectsBloc>(context);

    return Scaffold(
        appBar: AppBar(
          title: Text(L10N.of(context).tr.reports),
        ),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: Swiper(
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                      padding: Platform.isLinux || Platform.isMacOS
                          ? const EdgeInsets.symmetric(horizontal: 32)
                          : EdgeInsets.zero,
                      child: Builder(builder: (context) {
                        switch (index) {
                          case 0:
                            return ProjectBreakdown(
                              startDate: _startDate,
                              endDate: _endDate,
                              selectedProjects: selectedProjects,
                            );
                          case 1:
                            return WeeklyTotals(
                              startDate: _startDate,
                              endDate: _endDate,
                              selectedProjects: selectedProjects,
                            );
                          case 2:
                            return WeekdayAverages(
                              context,
                              startDate: _startDate,
                              endDate: _endDate,
                              selectedProjects: selectedProjects,
                            );
                          case 3:
                            return TimeTable(
                              startDate: _startDate,
                              endDate: _endDate,
                              selectedProjects: selectedProjects,
                            );
                          case 4:
                            return WeeklyProductivityDashboard(
                              startDate: _startDate,
                              endDate: _endDate,
                              selectedProjects: selectedProjects,
                            );
                        }
                        return const SizedBox();
                      }));
                },
                itemCount: 5,
                pagination: SwiperPagination(
                    builder: DotSwiperPaginationBuilder(
                  color: Theme.of(context).disabledColor,
                  activeColor: Theme.of(context).colorScheme.primary,
                )),
                control: Platform.isLinux || Platform.isMacOS
                    ? SwiperControl(
                        iconPrevious: Icons.arrow_back_ios_new,
                        iconNext: Icons.arrow_forward_ios,
                        color: Theme.of(context).colorScheme.onSurface)
                    : null,
              ),
            ),
            DateRangeTile(
                startDate: _startDate,
                endDate: _endDate,
                onStartChosen: (DateTime? dt) =>
                    setState(() => _startDate = dt),
                onEndChosen: (DateTime? dt) => setState(() => _endDate = dt)),
            ProjectTile(
              projects: projectsBloc.state.projects.where((p) => !p.archived),
              isEnabled: (project) =>
                  selectedProjects.any((p) => p?.id == project?.id),
              onToggled: (project) => setState(() {
                if (selectedProjects.any((p) => p?.id == project?.id)) {
                  selectedProjects.removeWhere((p) => p?.id == project?.id);
                } else {
                  selectedProjects.add(project);
                }
              }),
              onNoneSelected: () => setState(() {
                selectedProjects.clear();
              }),
              onAllSelected: () => selectedProjects = <Project?>[null]
                  .followedBy(projectsBloc.state.projects
                      .where((p) => !p.archived)
                      .map((p) => Project.clone(p)))
                  .toList(),
            ),
          ],
        ));
  }
}
