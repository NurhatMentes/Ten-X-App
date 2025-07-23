import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../shared/services/auth_service.dart';
import '../../domain/entities/decision.dart';
import '../bloc/decision_bloc.dart';
import '../bloc/decision_event.dart';
import '../bloc/decision_state.dart';
import '../widgets/create_decision_dialog.dart';
import '../widgets/decision_card.dart';
import '../widgets/decision_filter_widget.dart';
import '../widgets/decision_search_widget.dart';

/// Karar oylama ana sayfası
class DecisionVotingPage extends StatefulWidget {
  /// DecisionVotingPage constructor'ı
  const DecisionVotingPage({super.key});
  
  @override
  State<DecisionVotingPage> createState() => _DecisionVotingPageState();
}

class _DecisionVotingPageState extends State<DecisionVotingPage>
    with TickerProviderStateMixin {
  /// Tab controller
  late TabController _tabController;
  
  /// Scroll controller
  final ScrollController _scrollController = ScrollController();
  
  /// Arama controller'ı
  final TextEditingController _searchController = TextEditingController();
  
  /// Seçili kategori
  String? _selectedCategory;
  
  /// Arama aktif mi?
  bool _isSearching = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Scroll listener ekle
    _scrollController.addListener(_onScroll);
    
    // Tab değişikliği listener'ı
    _tabController.addListener(_onTabChanged);
    
    // İlk veriyi yükle
    _loadInitialData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  /// İlk veriyi yükleme
  void _loadInitialData() {
    context.read<DecisionBloc>().add(const GetPublicDecisionsEvent());
  }
  
  /// Tab değişikliği handler'ı
  void _onTabChanged() {
    if (!_tabController.indexIsChanging) return;
    
    final currentUserId = context.read<AuthService>().currentUserId ?? '';
    
    switch (_tabController.index) {
      case 0: // Herkese Açık
        context.read<DecisionBloc>().add(
          GetPublicDecisionsEvent(category: _selectedCategory),
        );
        break;
      case 1: // Arkadaşlar
        context.read<DecisionBloc>().add(
          GetFriendsDecisionsEvent(userId: currentUserId),
        );
        break;
      case 2: // Popüler
        context.read<DecisionBloc>().add(const GetPopularDecisionsEvent());
        break;
      case 3: // Kendi Kararlarım
        context.read<DecisionBloc>().add(
          GetUserDecisionsEvent(userId: currentUserId),
        );
        break;
    }
  }
  
  /// Scroll listener
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      _loadMoreData();
    }
  }
  
  /// Daha fazla veri yükleme
  void _loadMoreData() {
    final state = context.read<DecisionBloc>().state;
    
    if (state is DecisionsLoaded && state.hasMore) {
      final lastDecisionId = state.decisions.isNotEmpty
          ? state.decisions.last.id
          : null;
      
      final currentUserId = context.read<AuthService>().currentUserId ?? '';
      
      switch (_tabController.index) {
        case 0: // Herkese Açık
          context.read<DecisionBloc>().add(
            GetPublicDecisionsEvent(
              lastDecisionId: lastDecisionId,
              category: _selectedCategory,
            ),
          );
          break;
        case 1: // Arkadaşlar
          context.read<DecisionBloc>().add(
            GetFriendsDecisionsEvent(
              userId: currentUserId,
              lastDecisionId: lastDecisionId,
            ),
          );
          break;
        case 2: // Popüler
          context.read<DecisionBloc>().add(
            GetPopularDecisionsEvent(lastDecisionId: lastDecisionId),
          );
          break;
        case 3: // Kendi Kararlarım
          // Kullanıcının kararları için pagination yok
          break;
      }
    }
  }
  
  /// Arama yapma
  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _isSearching = false;
      });
      _onTabChanged(); // Mevcut tab'ı yenile
    } else {
      setState(() {
        _isSearching = true;
      });
      context.read<DecisionBloc>().add(
        SearchDecisionsEvent(query: query.trim()),
      );
    }
  }
  
  /// Kategori filtresi değişikliği
  void _onCategoryChanged(String? category) {
    setState(() {
      _selectedCategory = category;
    });
    
    if (_tabController.index == 0) {
      context.read<DecisionBloc>().add(
        GetPublicDecisionsEvent(category: category),
      );
    }
  }
  
  /// Yenileme
  Future<void> _onRefresh() async {
    context.read<DecisionBloc>().add(const RefreshDecisionsEvent());
  }
  
  /// Karar oluşturma dialog'u gösterme
  void _showCreateDecisionDialog() {
    showDialog(
      context: context,
      builder: (context) => const CreateDecisionDialog(),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Karar Oylama'),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              // Arama widget'ı
              DecisionSearchWidget(
                controller: _searchController,
                onSearch: _performSearch,
              ),
              
              // Tab bar
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Herkese Açık'),
                  Tab(text: 'Arkadaşlar'),
                  Tab(text: 'Popüler'),
                  Tab(text: 'Kararlarım'),
                ],
              ),
            ],
          ),
        ),
      ),
      
      body: Column(
        children: [
          // Filtre widget'ı (sadece herkese açık tab'ında)
          if (_tabController.index == 0 && !_isSearching)
            DecisionFilterWidget(
              selectedCategory: _selectedCategory,
              onCategoryChanged: _onCategoryChanged,
            ),
          
          // Ana içerik
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDecisionsList(), // Herkese Açık
                _buildDecisionsList(), // Arkadaşlar
                _buildDecisionsList(), // Popüler
                _buildDecisionsList(), // Kararlarım
              ],
            ),
          ),
        ],
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDecisionDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
  
  /// Kararlar listesi widget'ı
  Widget _buildDecisionsList() {
    return BlocBuilder<DecisionBloc, DecisionState>(
      builder: (context, state) {
        if (state is DecisionLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (state is DecisionError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Hata: ${state.message}',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _onRefresh,
                  child: const Text('Tekrar Dene'),
                ),
              ],
            ),
          );
        }
        
        if (state is DecisionEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  state.message,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                if (_tabController.index == 3) ...[
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _showCreateDecisionDialog,
                    child: const Text('İlk Kararını Oluştur'),
                  ),
                ],
              ],
            ),
          );
        }
        
        List<Decision> decisions = [];
        bool hasMore = false;
        bool isLoadingMore = false;
        
        if (state is DecisionsLoaded) {
          decisions = state.decisions;
          hasMore = state.hasMore;
        } else if (state is PublicDecisionsLoaded) {
          decisions = state.decisions;
          hasMore = state.hasMore;
        } else if (state is UserDecisionsLoaded) {
          decisions = state.decisions;
        } else if (state is FriendsDecisionsLoaded) {
          decisions = state.decisions;
          hasMore = state.hasMore;
        } else if (state is PopularDecisionsLoaded) {
          decisions = state.decisions;
          hasMore = state.hasMore;
        } else if (state is SearchResultsLoaded) {
          decisions = state.decisions;
          hasMore = state.hasMore;
        } else if (state is DecisionLoadingMore) {
          decisions = state.currentDecisions;
          isLoadingMore = true;
        } else if (state is DecisionRefreshing) {
          decisions = state.currentDecisions;
        }
        
        if (decisions.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        return RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: decisions.length + (hasMore || isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == decisions.length) {
                // Loading indicator for pagination
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              
              final decision = decisions[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: DecisionCard(
                  decision: decision,
                  onVote: (optionIndex) => _onVote(decision, optionIndex),
                  onEdit: _tabController.index == 3 ? () => _onEdit(decision) : null,
                  onDelete: _tabController.index == 3 ? () => _onDelete(decision) : null,
                ),
              );
            },
          ),
        );
      },
    );
  }
  
  /// Oy verme handler'ı
  void _onVote(Decision decision, int optionIndex) {
    final currentUserId = context.read<AuthService>().currentUserId ?? '';
    
    context.read<DecisionBloc>().add(
      VoteDecisionEvent(
        decisionId: decision.id,
        userId: currentUserId,
        optionIndex: optionIndex,
      ),
    );
  }
  
  /// Karar düzenleme handler'ı
  void _onEdit(Decision decision) {
    showDialog(
      context: context,
      builder: (context) => CreateDecisionDialog(decision: decision),
    );
  }
  
  /// Karar silme handler'ı
  void _onDelete(Decision decision) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kararı Sil'),
        content: Text('"${decision.title}" kararını silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<DecisionBloc>().add(
                DeleteDecisionEvent(decisionId: decision.id),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}