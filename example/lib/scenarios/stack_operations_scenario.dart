import 'package:material_ui/material_ui.dart';
import 'package:typed_navigator/typed_navigator.dart';
import 'package:typed_navigator_example/catalogue/scenario.dart';
import 'package:typed_navigator_example/catalogue/scenario_frame.dart';
import 'package:typed_navigator_example/support/demo_button.dart';
import 'package:typed_navigator_example/support/demo_page.dart';
import 'package:typed_navigator_example/support/material_page_factory.dart';
import 'package:typed_navigator_example/support/router_demo.dart';

const stackOperationsScenario = Scenario(
  title: 'replace, pushReplacement, popUntil, pushAndRemoveUntil',
  summary: 'The rest of the stack operations, on numbered steps.',
  instructions: [
    'Push a few steps, then "replace with step N + 10": the top page shows '
        'the new step in place, with no transition, as go_router\'s '
        'replace. "pushReplacement with step N + 20" slides a new page in, '
        'as Navigator\'s.',
    '"popUntil step 1" removes every step above step 1.',
    '"pushAndRemoveUntil step 99" leaves step 1 and puts step 99 on it, '
        'in one navigation; without step 1 it leaves step 99 alone, as '
        'Navigator does.',
    '"open a dialog", then its "router.pop": the dialog closes, the step '
        'stays, as Navigator.pop does.',
    '"pop" is disabled on the last step: router.canPop is false.',
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
          'pushReplacement with step ${number + 20}',
          onPressed: () => router.pushReplacement(StepRoute(number + 20)),
        ),
        DemoButton(
          'popUntil step 1',
          onPressed: hasFirstStep ? () => router.popUntil(_isFirstStep) : null,
        ),
        DemoButton(
          'pushAndRemoveUntil step 99',
          onPressed: () =>
              router.pushAndRemoveUntil(const StepRoute(99), _isFirstStep),
        ),
        DemoButton('open a dialog', onPressed: () => _openDialog(context)),
        DemoButton('pop', onPressed: router.canPop ? router.pop<void> : null),
      ],
    );
  }
}

void _openDialog(BuildContext context) => showDialog<void>(
  context: context,
  builder: (context) => AlertDialog(
    content: const Text('A dialog above the step'),
    actions: [
      TextButton(
        onPressed: () => TypedRouter.of(context).pop(),
        child: const Text('router.pop'),
      ),
    ],
  ),
);
