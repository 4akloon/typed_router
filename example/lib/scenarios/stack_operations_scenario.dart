import 'package:material_ui/material_ui.dart';
import 'package:typed_navigator/typed_navigator.dart';
import 'package:typed_navigator_example/catalogue/scenario.dart';
import 'package:typed_navigator_example/catalogue/scenario_frame.dart';
import 'package:typed_navigator_example/support/demo_button.dart';
import 'package:typed_navigator_example/support/demo_page.dart';
import 'package:typed_navigator_example/support/material_page_factory.dart';
import 'package:typed_navigator_example/support/router_demo.dart';

const stackOperationsScenario = Scenario(
  title: 'replace, popUntil, pushAndRemoveUntil',
  summary: 'The rest of the stack operations, on numbered steps.',
  instructions: [
    'Push a few steps, then "replace with step N + 10": the top step is '
        'swapped, the steps below stay.',
    '"popUntil step 1" removes every step above step 1.',
    '"pushAndRemoveUntil step 99" leaves step 1 and puts step 99 on it, '
        'in one navigation.',
    '"pop" is disabled on the last step: router.canPop is false. Replace '
        'step 1 itself and the two buttons that look for it are disabled.',
  ],
  build: _build,
);

Widget _build(ScenarioFrame frame) => RouterDemo(
  frame: frame,
  createRouter: () => TypedRouter(
    routes: [RouteNode<StepRoute>(build: (context, step) => _StepPage(step))],
    initialRoute: const StepRoute(1),
    pageFactory: const MaterialPageFactory(),
  ),
);

class StepRoute extends TypedRoute<void> {
  const StepRoute(this.number);

  final int number;

  @override
  List<Object?> get fields => [number];
}

bool _isFirstStep(TypedRoute<Object?> route) => route == const StepRoute(1);

class _StepPage extends StatelessWidget {
  const _StepPage(this.step);

  final StepRoute step;

  @override
  Widget build(BuildContext context) {
    final router = TypedRouter.of(context);
    final number = step.number;
    final hasFirstStep = router.state.routes.any(_isFirstStep);
    return DemoPage(
      title: 'Step $number',
      actions: [
        DemoButton(
          'push step ${number + 1}',
          onPressed: () => router.push(StepRoute(number + 1)),
        ),
        DemoButton(
          'replace with step ${number + 10}',
          onPressed: () => router.replace(StepRoute(number + 10)),
        ),
        DemoButton(
          'popUntil step 1',
          onPressed: hasFirstStep ? () => router.popUntil(_isFirstStep) : null,
        ),
        DemoButton(
          'pushAndRemoveUntil step 99',
          onPressed: hasFirstStep
              ? () =>
                    router.pushAndRemoveUntil(const StepRoute(99), _isFirstStep)
              : null,
        ),
        DemoButton('pop', onPressed: router.canPop ? router.pop<void> : null),
      ],
    );
  }
}
