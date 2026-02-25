import 'unit/connection_manager_test.dart' as connection_manager_test;
import 'unit/connection_path_test.dart' as connection_path_test;
import 'unit/graph_engine_test.dart' as graph_engine_test;
import 'unit/graph_utils_test.dart' as graph_utils_test;
import 'widgets/text_editing_node_body_test.dart'
    as text_editing_node_body_test;

void main() {
  connection_manager_test.main();
  connection_path_test.main();
  graph_engine_test.main();
  graph_utils_test.main();
  text_editing_node_body_test.main();
}
