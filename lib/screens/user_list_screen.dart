import 'package:flutter/material.dart';
import '../state/user_view_model.dart';
import '../screens/user_detail_screen.dart';
import '../Widgets/user_card.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen>
    with SingleTickerProviderStateMixin {
  final UserViewModel _viewModel = UserViewModel();
  late TabController _tabController;
  late Future<void> _initialLoad;   
  bool _showSearch = false; 
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initialLoad = _viewModel.fetchUsers(); 
    _viewModel.addListener(_onViewModelChanged); 
  }

  void _onViewModelChanged() {
    setState(() {}); 
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search students...',
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (text) => _viewModel.updateSearchQuery(text),
              )
            : const Text('Student Directory'),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) _viewModel.updateSearchQuery('');
              });
            },
          ),
        ],
      
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Users'),
            Tab(text: 'Favorites'),
          ],
        ),
      ),
            body: FutureBuilder<void>(
        future: _initialLoad,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return TabBarView(
            controller: _tabController,
            children: [
              _buildUserList(_viewModel.filteredUsers),
              _buildUserList(_viewModel.favoriteUsers),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUserList(List users) {
    
    if (_viewModel.state == ViewState.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    
    if (_viewModel.state == ViewState.error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_viewModel.errorMessage),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _viewModel.fetchUsers,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    
    if (users.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_off, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text('No users found'),
          ],
        ),
      );
    }

   
    return RefreshIndicator(
      onRefresh: _viewModel.fetchUsers,
      
      child: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return UserCard(
            user: user,
            isFavorite: _viewModel.isFavorite(user.id),
            onFavoriteToggle: () => _viewModel.toggleFavorite(user.id),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UserDetailScreen(user: user),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

