import 'package:aiphotokit/data/image_service.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> get defaultProviders {
  return [Provider(create: (context) => ImageService())];
}
