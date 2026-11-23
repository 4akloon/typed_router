part of 'shell_level.dart';

/// One instance of a shell on the stack.
///
/// The same instance keeps its navigator and the state of its frame; a new
/// instance of the same node is another navigator. A shell no entry stands
/// in does not exist.
class ShellEntry extends ShellLevel {
  /// Creates a new instance of [node].
  ShellEntry(this.node);

  /// The node this instance shows.
  final ShellNode<Object?> node;

  @override
  NavigatorSlot? get slot => node.navigatorSlot;

  @override
  bool isInstanceOf(Nesting nesting) =>
      nesting is ShellNesting && identical(nesting.node, node);

  @override
  ShellLevel? takenOverFor(Nesting nesting) =>
      isInstanceOf(nesting) ? this : null;

  @override
  String toString() => 'ShellEntry(${identityHashCode(this)})';
}
