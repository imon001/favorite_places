import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../providers/handle_user_place_provider.dart';
import '../widgets/places_list_item.dart';
import 'add_place_screen.dart';

class PlacesListScreen extends ConsumerStatefulWidget {
  const PlacesListScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PlacesListScreenState();
}

class _PlacesListScreenState extends ConsumerState<PlacesListScreen> {
  late Future<void> _placesFuture;
  // void _deleteAll() async {
  //   await ref.read(handleUserPlaceProvider.notifier).deleteAllData();
  // }

  @override
  void initState() {
    super.initState();
    _placesFuture = ref.read(handleUserPlaceProvider.notifier).loadPlaces();
    //_deleteAll();
  }

  @override
  Widget build(BuildContext context) {
    final userPlaces = ref.watch(handleUserPlaceProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Places List "),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const AddPlaceScreen()));
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: FutureBuilder(
          future: _placesFuture,
          builder: (context, snapshot) => snapshot.connectionState == ConnectionState.waiting
              ? Center(
                  child: SizedBox(
                    width: 55,
                    child: LoadingIndicator(
                      indicatorType: Indicator.lineSpinFadeLoader,
                      colors: [Theme.of(context).colorScheme.onPrimary],
                      strokeWidth: 2,
                      pathBackgroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                )
              : PlacesListItem(
                  places: userPlaces,
                ),
        ),
      ),
    );
  }
}
