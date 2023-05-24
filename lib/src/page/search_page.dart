import 'package:flutter/material.dart';
import '../feature/apiService.dart';
import '../feature/token.dart';
import 'search_list_page.dart'; // Please create this file

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<dynamic> searchResults = [];
  List<String> searchHistory = []; // Temporary Search History
  String? accessToken;
  int page = 1;
  String searchText = '';
  bool _hasMore = true;
  bool _isSearching = false;
  ScrollController _scrollController = ScrollController();
  bool _isFetching = false;

  @override
  void initState() {
    super.initState();
    fetchAccessToken().then((token) {
      accessToken = token;
      fetchPosts();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchPosts({bool refresh = false}) async {
    if (refresh) {
      searchResults.clear();
      page = 1;
      _hasMore = true;
    }

    if (!_isFetching && _hasMore) {
      _isFetching = true;

      List<dynamic> newPosts = await getHotPosts(accessToken, page);

      if (newPosts.isEmpty) {
        _hasMore = false;
      } else {
        setState(() {
          // Filter out the existing posts
          newPosts = newPosts.where((newPost) {
            return !searchResults.any((oldPost) => oldPost['id'] == newPost['id']);
          }).toList();

          searchResults.addAll(newPosts);
          page++;
        });
      }

      _isFetching = false;
    }
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final reachToBottom = maxScroll - currentScroll < 2 * MediaQuery.of(context).size.height;

    if (_scrollController.position.atEdge) {
      if (_scrollController.position.pixels != 0 && _hasMore) {
        fetchPosts();
      }
    } else {
      int currentIndex = (currentScroll / maxScroll * searchResults.length).floor();
      if (searchResults.length - currentIndex <= 2 && _hasMore) {
        fetchPosts();
      }
    }
  }

  Future<void> _refreshPosts() async {
    await fetchPosts(refresh: true);
  }

  void _addSearchHistory(String search) {
    if (!searchHistory.contains(search)) {
      searchHistory.insert(0, search);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshPosts,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[
            SliverAppBar(
              title: _isSearching
                  ? TextField(
                onSubmitted: (value) {
                  setState(() {
                    searchText = value;
                    _addSearchHistory(value);
                    _isSearching = false;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search...',
                ),
              )
                  : Text('인기 게시물', style: TextStyle(color: Colors.black)),
              actions: [
                IconButton(
                  icon: Icon(Icons.search, color: Colors.black),
                  onPressed: () {
                    setState(() {
                      _isSearching = true;
                    });
                  },
                ),
                if (_isSearching)
                  IconButton(
                    icon: Icon(Icons.cancel, color: Colors.black),
                    onPressed: () {
                      setState(() {
                        _isSearching = false;
                      });
                    },
                  ),
              ],
              floating: true,
            ),
            SliverPadding(
              padding: const EdgeInsets.all(4.0),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 1.0, // You can adjust these values as per your requirement
                  crossAxisSpacing: 1.0,
                  childAspectRatio: 1.0,
                ),
                delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                    if (index == searchResults.length && _hasMore) {
                      // Return loading indicator in the bottom center
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    } else if (index < searchResults.length) {
                      return Container(
                        color: Colors.white,
                        margin: EdgeInsets.all(1),
                        child: GestureDetector(
                          onTap: () {
                            print('Image clicked: ${searchResults[index]['id']}');
                          },
                          child: Image.network(searchResults[index]['image_url']),
                        ),
                      );
                    } else {
                      // If there is no more data, return an empty container
                      return Container();
                    }
                  },
                  // Increase childCount by 1 if there might be more posts
                  childCount: searchResults.length + (_hasMore ? 1 : 0),
                ),
              ),
            ),
          ],
        ),
      ),
      drawer: _isSearching ? _buildSearchHistory() : null,
    );
  }

  Widget _buildSearchHistory() {
    return ListView.builder(
      itemCount: searchHistory.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(searchHistory[index]),
        );
      },
    );
  }
}