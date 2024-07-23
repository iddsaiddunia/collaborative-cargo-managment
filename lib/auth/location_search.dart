import 'package:flutter/material.dart';
import 'package:flutter_google_maps_webservices/places.dart';

class SearchPlacesPage extends StatefulWidget {
  @override
  _SearchPlacesPageState createState() => _SearchPlacesPageState();
}

class _SearchPlacesPageState extends State<SearchPlacesPage> {
  final TextEditingController _searchController = TextEditingController();
  List<PlacesSearchResult> _searchResults = [];

  Future<void> _searchPlaces(String query) async {
    final googlePlaces = GoogleMapsPlaces(apiKey: 'AIzaSyAjsJbodhou5nNntMWPdhRsWqz2h1Tgzoc'); // Replace with your API key
    final response = await googlePlaces.searchByText(query);

    if (response.status == 'OK' && response.results.isNotEmpty) {
      setState(() {
        _searchResults = response.results;
      });
    } else {
      setState(() {
        _searchResults = [];
      });
      print('Error searching places: ${response.errorMessage}');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Places'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for a place',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _searchPlaces(_searchController.text);
                  },
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_searchResults[index].name),
                    onTap: () {
                      Navigator.pop(context, _searchResults[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
