import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mimd_task/core/navigator/app_rouutes.dart';
import 'package:mimd_task/features/home/view/home_view.dart';
import 'package:mimd_task/features/place_holders/view/place_holders_view.dart';
import 'package:mimd_task/features/todo/view/add_todo_view.dart';
import 'package:mimd_task/features/todo/view/todo_listview.dart';


class RouterConfig {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      // Home Route
      GoRoute(
        path: AppRoutes.home,
        pageBuilder: (context, state) => _buildPageWithTransition(
          child: const HomeView(),
          state: state,
        ),
      ),
      
      // Todo Routes
      GoRoute(
        path: AppRoutes.todoList,
        pageBuilder: (context, state) => _buildPageWithTransition(
          child: const TodoListView(),
          state: state,
        ),
        routes: [
          GoRoute(
            path: 'add',
            pageBuilder: (context, state) => _buildPageWithTransition(
              child: const AddTodoView(),
              state: state,
              transitionType: _TransitionType.slideUp,
            ),
          ),
          GoRoute(
            path: 'edit/:id',
            pageBuilder: (context, state) => _buildPageWithTransition(
              child: EditTodoView(todoId: state.pathParameters['id']!),
              state: state,
              transitionType: _TransitionType.slideUp,
            ),
          ),
          GoRoute(
            path: 'details/:id',
            pageBuilder: (context, state) => _buildPageWithTransition(
              child: TodoDetailsView(todoId: state.pathParameters['id']!),
              state: state,
            ),
          ),
          GoRoute(
            path: 'completed',
            pageBuilder: (context, state) => _buildPageWithTransition(
              child: const CompletedTodosView(),
              state: state,
            ),
          ),
          GoRoute(
            path: 'map',
            pageBuilder: (context, state) => _buildPageWithTransition(
              child: const TodoMapView(),
              state: state,
            ),
          ),
          GoRoute(
            path: 'statistics',
            pageBuilder: (context, state) => _buildPageWithTransition(
              child: const TodoStatisticsView(),
              state: state,
            ),
          ),
        ],
      ),
      
      // Notes Routes
      GoRoute(
        path: AppRoutes.notesList,
        pageBuilder: (context, state) => _buildPageWithTransition(
          child: const NotesListView(),
          state: state,
        ),
        routes: [
          GoRoute(
            path: 'add',
            pageBuilder: (context, state) => _buildPageWithTransition(
              child: const AddNoteView(),
              state: state,
              transitionType: _TransitionType.slideUp,
            ),
          ),
          GoRoute(
            path: 'edit/:id',
            pageBuilder: (context, state) => _buildPageWithTransition(
              child: EditNoteView(noteId: state.pathParameters['id']!),
              state: state,
              transitionType: _TransitionType.slideUp,
            ),
          ),
          GoRoute(
            path: 'details/:id',
            pageBuilder: (context, state) => _buildPageWithTransition(
              child: NoteDetailsView(noteId: state.pathParameters['id']!),
              state: state,
            ),
          ),
        ],
      ),
      
      // AI Routes
      GoRoute(
        path: AppRoutes.aiTaskOrganizer,
        pageBuilder: (context, state) => _buildPageWithTransition(
          child: const AiTaskOrganizerView(),
          state: state,
          transitionType: _TransitionType.fadeScale,
        ),
      ),
      GoRoute(
        path: AppRoutes.aiTaskMap,
        pageBuilder: (context, state) => _buildPageWithTransition(
          child: AiTaskMapView(
            tasks: state.extra as List<Map<String, dynamic>>? ?? [],
          ),
          state: state,
        ),
      ),
      
      // Settings Routes
      GoRoute(
        path: AppRoutes.settings,
        pageBuilder: (context, state) => _buildPageWithTransition(
          child: const SettingsView(),
          state: state,
        ),
        routes: [
          GoRoute(
            path: 'categories',
            pageBuilder: (context, state) => _buildPageWithTransition(
              child: const CategoriesView(),
              state: state,
            ),
          ),
        ],
      ),
      
      // Common Routes
      GoRoute(
        path: AppRoutes.search,
        pageBuilder: (context, state) => _buildPageWithTransition(
          child: SearchView(
            searchType: state.uri.queryParameters['type'] ?? 'all',
          ),
          state: state,
          transitionType: _TransitionType.fadeScale,
        ),
      ),
      GoRoute(
        path: AppRoutes.categoryFilter,
        pageBuilder: (context, state) => _buildPageWithTransition(
          child: CategoryFilterView(
            filterType: state.uri.queryParameters['type'] ?? 'todo',
          ),
          state: state,
          transitionType: _TransitionType.slideUp,
        ),
      ),
    ],
    errorPageBuilder: (context, state) => MaterialPage(
      key: state.pageKey,
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Page not found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'The page you are looking for does not exist.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

enum _TransitionType {
  slideRight,
  slideLeft,
  slideUp,
  slideDown,
  fade,
  fadeScale,
}

Page _buildPageWithTransition({
  required Widget child,
  required GoRouterState state,
  _TransitionType transitionType = _TransitionType.slideRight,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionType: transitionType,
  );
}

class CustomTransitionPage extends Page {
  final Widget child;
  final _TransitionType transitionType;

  const CustomTransitionPage({
    required this.child,
    required this.transitionType,
    super.key,
  });

  @override
  Route createRoute(BuildContext context) {
    return PageRouteBuilder(
      settings: this,
      pageBuilder: (context, animation, _) => child,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        switch (transitionType) {
          case _TransitionType.slideRight:
            return SlideTransition(
              position: animation.drive(
                Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.easeInOut)),
              ),
              child: child,
            );
          case _TransitionType.slideLeft:
            return SlideTransition(
              position: animation.drive(
                Tween<Offset>(
                  begin: const Offset(-1.0, 0.0),
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.easeInOut)),
              ),
              child: child,
            );
          case _TransitionType.slideUp:
            return SlideTransition(
              position: animation.drive(
                Tween<Offset>(
                  begin: const Offset(0.0, 1.0),
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.easeInOut)),
              ),
              child: child,
            );
          case _TransitionType.slideDown:
            return SlideTransition(
              position: animation.drive(
                Tween<Offset>(
                  begin: const Offset(0.0, -1.0),
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.easeInOut)),
              ),
              child: child,
            );
          case _TransitionType.fade:
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          case _TransitionType.fadeScale:
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: animation.drive(
                  Tween<double>(begin: 0.8, end: 1.0)
                      .chain(CurveTween(curve: Curves.easeInOut)),
                ),
                child: child,
              ),
            );
        }
      },
    );
  }
}