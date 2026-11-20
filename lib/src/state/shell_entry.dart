part of 'shell_level.dart';

/// One instance of a shell on the stack.
///
/// The same instance keeps its navigator and the state of its frame; a new
/// instance of the same node is another navigator. A shell no entry stands
/// in does not exist.
final class ShellEntry extends ShellLevel implements ColumnOwner {
  /// Creates a new instance of [node].
  ShellEntry(this.node);

  /// The node this instance shows.
  final ShellNode<Object?> node;

  /// Keys the frame the shell's builder makes, so it keeps its state when a
  /// split moves the shell's page to another navigator.
  final GlobalKey frameKey = GlobalKey();

  @override
  GlobalKey get pageContentKey => frameKey;

  @override
  ColumnOwner get columnOwner => this;

  @override
  bool isInstanceOf(Nesting nesting) =>
      nesting is ShellNesting && identical(nesting.node, node);

  @override
  ShellLevel? takenOverFor(Nesting nesting) =>
      isInstanceOf(nesting) ? this : null;

  @override
  String toString() => 'ShellEntry(${identityHashCode(this)})';
}
