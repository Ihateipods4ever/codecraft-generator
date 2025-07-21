import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart'; // Keep sizer for overall responsive layout, but use sparingly for fixed elements

import '../../core/app_export.dart';
import './widgets/category_section_widget.dart';
import './widgets/filter_chip_widget.dart';
import './widgets/popular_template_card_widget.dart';
import './widgets/template_card_widget.dart';
// Ensure AppRoutes is imported

class TemplateLibrary extends StatefulWidget {
  const TemplateLibrary({Key? key}) : super(key: key);

  @override
  State<TemplateLibrary> createState() => _TemplateLibraryState();
}

class _TemplateLibraryState extends State<TemplateLibrary>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _searchQuery = '';
  List<String> _selectedFrameworks = [];
  bool _isSearching = false;

  // Mock data for templates
  final List<Map<String, dynamic>> _popularTemplates = [
    {
      "id": "pop_1",
      "name": "E-commerce Dashboard",
      "framework": "React",
      "category": "Web Apps",
      "image":
          "https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=800&h=450&fit=crop",
      "popularity": 4.8,
      "downloads": "12.5k",
      "description":
          "Complete e-commerce admin dashboard with analytics, product management, and order tracking.",
      "isFavorite": false,
      "tags": ["dashboard", "ecommerce", "analytics"]
    },
    {
      "id": "pop_2",
      "name": "Mobile Banking App",
      "framework": "Flutter",
      "category": "Mobile Apps",
      "image":
          "https://images.unsplash.com/photo-1563013544-824ae1b704d3?w=800&h=450&fit=crop",
      "popularity": 4.9,
      "downloads": "8.3k",
      "description":
          "Secure mobile banking application with biometric authentication and transaction history.",
      "isFavorite": true,
      "tags": ["banking", "mobile", "security"]
    },
    {
      "id": "pop_3",
      "name": "REST API Boilerplate",
      "framework": "Node.js",
      "category": "APIs",
      "image":
          "https://images.unsplash.com/photo-1558494949-ef010cbdcc31?w=800&h=450&fit=crop",
      "popularity": 4.7,
      "downloads": "15.2k",
      "description":
          "Production-ready REST API with authentication, validation, and database integration.",
      "isFavorite": false,
      "tags": ["api", "backend", "authentication"]
    }
  ];

  final List<Map<String, dynamic>> _categories = [
    {
      "name": "Web Apps",
      "icon": "web",
      "count": 45,
      "templates": [
        {
          "id": "web_1",
          "name": "Portfolio Website",
          "framework": "Vue",
          "image":
              "https://images.unsplash.com/photo-1467232004584-a241de8bcf5d?w=400&h=225&fit=crop",
          "popularity": 4.6,
          "downloads": "3.2k",
          "description":
              "Modern portfolio website with smooth animations and responsive design.",
          "isFavorite": false,
          "tags": ["portfolio", "responsive", "animations"]
        },
        {
          "id": "web_2",
          "name": "Blog Platform",
          "framework": "React",
          "image":
              "https://images.unsplash.com/photo-1486312338219-ce68d2c6f44d?w=400&h=225&fit=crop",
          "popularity": 4.4,
          "downloads": "2.8k",
          "description":
              "Full-featured blog platform with CMS integration and SEO optimization.",
          "isFavorite": true,
          "tags": ["blog", "cms", "seo"]
        },
        {
          "id": "web_3",
          "name": "Task Management",
          "framework": "Angular",
          "image":
              "https://images.unsplash.com/photo-1611224923853-80b023f02d71?w=400&h=225&fit=crop",
          "popularity": 4.5,
          "downloads": "4.1k",
          "description":
              "Collaborative task management application with real-time updates.",
          "isFavorite": false,
          "tags": ["productivity", "collaboration", "realtime"]
        }
      ]
    },
    {
      "name": "Mobile Apps",
      "icon": "phone_android",
      "count": 32,
      "templates": [
        {
          "id": "mobile_1",
          "name": "Fitness Tracker",
          "framework": "Flutter",
          "image":
              "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=225&fit=crop",
          "popularity": 4.7,
          "downloads": "5.6k",
          "description":
              "Comprehensive fitness tracking app with workout plans and progress monitoring.",
          "isFavorite": false,
          "tags": ["fitness", "health", "tracking"]
        },
        {
          "id": "mobile_2",
          "name": "Food Delivery",
          "framework": "React Native",
          "image":
              "https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=400&h=225&fit=crop",
          "popularity": 4.8,
          "downloads": "7.2k",
          "description":
              "Complete food delivery app with restaurant listings and order tracking.",
          "isFavorite": true,
          "tags": ["food", "delivery", "ecommerce"]
        }
      ]
    },
    {
      "name": "APIs",
      "icon": "api",
      "count": 28,
      "templates": [
        {
          "id": "api_1",
          "name": "GraphQL Server",
          "framework": "Node.js",
          "image":
              "https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=400&h=225&fit=crop",
          "popularity": 4.5,
          "downloads": "3.9k",
          "description":
              "Scalable GraphQL server with type-safe schema and real-time subscriptions.",
          "isFavorite": false,
          "tags": ["graphql", "server", "realtime"]
        },
        {
          "id": "api_2",
          "name": "Microservices Kit",
          "framework": "Python",
          "image":
              "https://images.unsplash.com/photo-1518432031352-d6fc5c10da5a?w=400&h=225&fit=crop",
          "popularity": 4.6,
          "downloads": "4.7k",
          "description":
              "Microservices architecture template with Docker and Kubernetes support.",
          "isFavorite": false,
          "tags": ["microservices", "docker", "kubernetes"]
        }
      ]
    },
    {
      "name": "Components",
      "icon": "widgets",
      "count": 67,
      "templates": [
        {
          "id": "comp_1",
          "name": "UI Component Library",
          "framework": "React",
          "image":
              "https://images.unsplash.com/photo-1581291518857-4e27b48ff24e?w=400&h=225&fit=crop",
          "popularity": 4.9,
          "downloads": "9.1k",
          "description":
              "Comprehensive UI component library with Storybook documentation.",
          "isFavorite": true,
          "tags": ["components", "ui", "storybook"]
        },
        {
          "id": "comp_2",
          "name": "Chart Components",
          "framework": "Vue",
          "image":
              "https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=400&h=225&fit=crop",
          "popularity": 4.4,
          "downloads": "2.3k",
          "description":
              "Interactive chart components with customizable themes and animations.",
          "isFavorite": false,
          "tags": ["charts", "visualization", "interactive"]
        }
      ]
    },
    {
      "name": "Full-Stack",
      "icon": "layers",
      "count": 19,
      "templates": [
        {
          "id": "full_1",
          "name": "SaaS Starter Kit",
          "framework": "Next.js",
          "image":
              "https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=400&h=225&fit=crop",
          "popularity": 4.8,
          "downloads": "6.4k",
          "description":
              "Complete SaaS application with authentication, payments, and admin dashboard.",
          "isFavorite": false,
          "tags": ["saas", "fullstack", "payments"]
        },
        {
          "id": "full_2",
          "name": "Social Media Platform",
          "framework": "MERN",
          "image":
              "https://images.unsplash.com/photo-1611162617474-5b21e879e113?w=400&h=225&fit=crop",
          "popularity": 4.7,
          "downloads": "5.8k",
          "description":
              "Full-featured social media platform with posts, messaging, and notifications.",
          "isFavorite": true,
          "tags": ["social", "messaging", "notifications"]
        }
      ]
    }
  ];

  final List<String> _frameworks = [
    "React",
    "Vue",
    "Angular",
    "Flutter",
    "React Native",
    "Node.js",
    "Python",
    "Next.js",
    "MERN",
    "Django"
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this, initialIndex: 4);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _isSearching = query.isNotEmpty;
    });
  }

  void _toggleFrameworkFilter(String framework) {
    setState(() {
      _selectedFrameworks.contains(framework)
          ? _selectedFrameworks.remove(framework)
          : _selectedFrameworks.add(framework);
    });
  }

  void _toggleFavorite(String templateId, String category) {
    setState(() {
      if (category == "popular") {
        final template =
            _popularTemplates.firstWhere((t) => t["id"] == templateId);
        template["isFavorite"] = !template["isFavorite"];
      } else {
        for (var cat in _categories) {
          final templates = cat["templates"] as List<Map<String, dynamic>>;
          final template =
              templates.where((t) => t["id"] == templateId).firstOrNull;
          if (template != null) {
            template["isFavorite"] = !template["isFavorite"];
            break;
          }
        }
      }
    });
    HapticFeedback.lightImpact();
  }

  void _showTemplatePreview(Map<String, dynamic> template) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildTemplatePreviewModal(template),
    );
  }

  void _useTemplate(Map<String, dynamic> template) {
    Navigator.pop(context);
    Navigator.pushNamed(context, '/code-generation-screen');
  }

  // New method to navigate to a screen showing all templates for a category
  void _showAllTemplatesForCategory(Map<String, dynamic> categoryData) {
    Navigator.pushNamed(
      context,
      AppRoutes.allTemplatesScreen,
      arguments: categoryData, // Pass the entire category data
    );
  }

  List<Map<String, dynamic>> _getFilteredTemplates(
      List<Map<String, dynamic>> templates) {
    return templates.where((template) {
      final matchesSearch = _searchQuery.isEmpty ||
          template["name"].toString().toLowerCase().contains(_searchQuery) ||
          template["description"]
              .toString()
              .toLowerCase()
              .contains(_searchQuery) ||
          (template["tags"] as List).any(
              (tag) => tag.toString().toLowerCase().contains(_searchQuery));

      final matchesFramework = _selectedFrameworks.isEmpty ||
          _selectedFrameworks.contains(template["framework"]);

      return matchesSearch && matchesFramework;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            _buildSearchAndFilters(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await Future.delayed(const Duration(seconds: 1));
                  HapticFeedback.lightImpact();
                },
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Fixed padding
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: AppTheme.getSubtleShadow(isLight: true),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8.0), // Fixed padding
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8.0), // Fixed border radius
                border: Border.all(
                  color: AppTheme.lightTheme.dividerColor,
                  width: 1,
                ),
              ),
              child: CustomIconWidget(
                iconName: 'arrow_back',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 24.0, // Fixed icon size
              ),
            ),
          ),
          const SizedBox(width: 16.0), // Fixed spacing
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Template Library',
                  style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 20.0, // Fixed font size
                  ),
                ),
                Text(
                  '191 templates available',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    fontSize: 12.0, // Fixed font size
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              // Navigate to favorites
            },
            child: Container(
              padding: const EdgeInsets.all(8.0), // Fixed padding
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8.0), // Fixed border radius
                border: Border.all(
                  color: AppTheme.lightTheme.dividerColor,
                  width: 1,
                ),
              ),
              child: CustomIconWidget(
                iconName: 'favorite_border',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 24.0, // Fixed icon size
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppTheme.lightTheme.colorScheme.surface,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: AppTheme.lightTheme.colorScheme.primary,
        unselectedLabelColor: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        indicatorColor: AppTheme.lightTheme.colorScheme.primary,
        indicatorWeight: 3,
        labelStyle: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 14.0, // Fixed font size
        ),
        unselectedLabelStyle: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
          fontSize: 14.0, // Fixed font size
        ),
        tabs: const [ // Made const
          Tab(text: 'Splash'),
          Tab(text: 'Onboarding'),
          Tab(text: 'Dashboard'),
          Tab(text: 'Generation'),
          Tab(text: 'Templates'),
          Tab(text: 'Preview'),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16.0), // Fixed padding
      color: AppTheme.lightTheme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align children to start
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(10.0), // Fixed border radius
              border: Border.all(
                color: AppTheme.lightTheme.dividerColor,
                width: 1,
              ),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search templates, frameworks, or features...',
                hintStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  fontSize: 16.0, // Fixed font size for hint
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12.0), // Fixed padding
                  child: CustomIconWidget(
                    iconName: 'search',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 20.0, // Fixed icon size
                  ),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0), // Fixed padding
                          child: CustomIconWidget(
                            iconName: 'close',
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                            size: 20.0, // Fixed icon size
                          ),
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0, // Fixed padding
                  vertical: 12.0, // Fixed padding
                ),
              ),
            ),
          ),
          const SizedBox(height: 16.0), // Increased spacing for filter title
          // Title for Filter Chips
          Text(
            'Filter by Framework',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 18.0, // Adjusted font size for filter title
            ),
          ),
          const SizedBox(height: 8.0), // Spacing between title and chips
          // Filter Chips
          SizedBox(
            height: 40.0, // Fixed height
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _frameworks.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8.0), // Fixed spacing
              itemBuilder: (context, index) {
                final framework = _frameworks[index];
                final isSelected = _selectedFrameworks.contains(framework);

                // Assuming FilterChipWidget also uses fixed pixel values internally
                return FilterChipWidget(
                  label: framework,
                  isSelected: isSelected,
                  onTap: () => _toggleFrameworkFilter(framework),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildPlaceholderTab('Splash Screen'),
        _buildPlaceholderTab('Onboarding Flow'),
        _buildPlaceholderTab('Dashboard'),
        _buildPlaceholderTab('Code Generation'),
        _buildTemplatesContent(),
        _buildPlaceholderTab('Preview'),
      ],
    );
  }

  Widget _buildPlaceholderTab(String title) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0), // Increased padding for content
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'construction',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 100.0, // Fixed icon size
            ),
            const SizedBox(height: 24.0), // Fixed spacing
            Text(
              title,
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontSize: 24.0, // Fixed font size
              ),
              textAlign: TextAlign.center, // Center text
            ),
            const SizedBox(height: 8.0), // Fixed spacing
            Text(
              'Coming Soon',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                fontSize: 16.0, // Fixed font size
              ),
              textAlign: TextAlign.center, // Center text
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplatesContent() {
    final filteredPopularTemplates = _getFilteredTemplates(_popularTemplates);

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Popular Templates Section
        if (filteredPopularTemplates.isNotEmpty && !_isSearching) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0), // Fixed padding
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'trending_up',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 28.0, // Fixed icon size
                  ),
                  const SizedBox(width: 8.0), // Fixed spacing
                  Text(
                    'Popular Templates',
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 20.0, // Fixed font size
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 200.0, // Fixed height for horizontal list
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0), // Fixed padding
                itemCount: filteredPopularTemplates.length,
                separatorBuilder: (context, index) => const SizedBox(width: 16.0), // Fixed spacing
                itemBuilder: (context, index) {
                  final template = filteredPopularTemplates[index];
                  // Assuming PopularTemplateCardWidget also uses fixed pixel values internally
                  return PopularTemplateCardWidget(
                    template: template,
                    onTap: () => _showTemplatePreview(template),
                    onFavorite: () =>
                        _toggleFavorite(template["id"], "popular"),
                  );
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24.0)), // Fixed spacing
        ],

        // Categories
        ...(_isSearching ? _buildSearchResults() : _buildCategoryResults()),
      ],
    );
  }

  List<Widget> _buildSearchResults() {
    final allTemplates = <Map<String, dynamic>>[];

    // Add popular templates
    allTemplates.addAll(_popularTemplates);

    // Add category templates
    for (var category in _categories) {
      final templates = category["templates"] as List<Map<String, dynamic>>;
      allTemplates.addAll(templates);
    }

    final filteredTemplates = _getFilteredTemplates(allTemplates);

    if (filteredTemplates.isEmpty) {
      return [
        SliverFillRemaining(
          child: _buildEmptySearchResults(),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.all(16.0), // Fixed padding
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7, // Adjusted aspect ratio for cards
            crossAxisSpacing: 16.0, // Fixed spacing
            mainAxisSpacing: 16.0, // Fixed spacing
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final template = filteredTemplates[index];
              // Assuming TemplateCardWidget also uses fixed pixel values internally
              return TemplateCardWidget(
                template: template,
                onTap: () => _showTemplatePreview(template),
                onFavorite: () => _toggleFavorite(template["id"], "search"),
              );
            },
            childCount: filteredTemplates.length,
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildCategoryResults() {
    final widgets = <Widget>[];

    for (var category in _categories) {
      final templates = category["templates"] as List<Map<String, dynamic>>;
      final filteredTemplates = _getFilteredTemplates(templates);

      if (filteredTemplates.isNotEmpty) {
        widgets.add(
          SliverToBoxAdapter(
            child: CategorySectionWidget(
              category: category,
              templates: filteredTemplates,
              onTemplatePreview: _showTemplatePreview,
              onToggleFavorite: _toggleFavorite,
              onViewAll: () => _showAllTemplatesForCategory(category), // Pass the new callback here
            ),
          ),
        );
        widgets.add(const SliverToBoxAdapter(child: SizedBox(height: 24.0))); // Fixed spacing
      }
    }

    return widgets;
  }

  Widget _buildEmptySearchResults() {
    return Center(
      child: SingleChildScrollView( // Added SingleChildScrollView
        padding: const EdgeInsets.all(24.0), // Fixed padding
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'search_off',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 100.0, // Fixed icon size
            ),
            const SizedBox(height: 24.0), // Fixed spacing
            Text(
              'No templates found',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontSize: 24.0, // Fixed font size
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8.0), // Fixed spacing
            Text(
              'Try adjusting your search or filters, or create a custom template.',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                fontSize: 16.0, // Fixed font size
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32.0), // Fixed spacing
            ElevatedButton(
              onPressed: () =>
                  Navigator.pushNamed(context, '/code-generation-screen'),
              child: Text(
                'Generate Custom Code',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  fontSize: 16.0, // Fixed font size
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplatePreviewModal(Map<String, dynamic> template) {
    return Container(
      height: 70.h, // Still use h for overall modal height, but a smaller percentage
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)), // Fixed border radius
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 48.0, // Fixed width
            height: 4.0, // Fixed height
            margin: const EdgeInsets.symmetric(vertical: 12.0), // Fixed margin
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.dividerColor,
              borderRadius: BorderRadius.circular(2.0), // Fixed border radius
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0), // Fixed padding
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template["name"],
                        style:
                            AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 20.0, // Fixed font size
                        ),
                      ),
                      Text(
                        template["framework"],
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontSize: 14.0, // Fixed font size
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8.0), // Fixed padding
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8.0), // Fixed border radius
                      border: Border.all(
                        color: AppTheme.lightTheme.dividerColor,
                        width: 1,
                      ),
                    ),
                    child: CustomIconWidget(
                      iconName: 'close',
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      size: 24.0, // Fixed icon size
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16.0), // Fixed spacing

          // Preview Image
          Container(
            height: 180.0, // Fixed height
            margin: const EdgeInsets.symmetric(horizontal: 16.0), // Fixed margin
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0), // Fixed border radius
              boxShadow: AppTheme.getSubtleShadow(isLight: true),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0), // Fixed border radius
              child: CustomImageWidget(
                imageUrl: template["image"],
                width: double.infinity,
                height: 180.0, // Fixed height
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(height: 16.0), // Fixed spacing

          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0), // Fixed padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'star',
                          color: Colors.amber,
                          size: 18.0, // Fixed icon size
                        ),
                        const SizedBox(width: 4.0), // Fixed spacing
                        Text(
                          '${template["popularity"]} (${template["downloads"]} downloads)',
                          style: AppTheme.lightTheme.textTheme.bodyMedium,
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => _toggleFavorite(template["id"], "modal"),
                          child: CustomIconWidget(
                            iconName: template["isFavorite"]
                                ? 'favorite'
                                : 'favorite_border',
                            color: template["isFavorite"]
                                ? Colors.red
                                : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                            size: 24.0, // Fixed icon size
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0), // Fixed spacing

                    // Description
                    Text(
                      'Description',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16.0, // Fixed font size
                      ),
                    ),
                    const SizedBox(height: 8.0), // Fixed spacing
                    Text(
                      template["description"],
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16.0), // Fixed spacing

                    // Tags
                    if ((template["tags"] as List).isNotEmpty) ...[
                      Text(
                        'Tags',
                        style: AppTheme.lightTheme.textTheme.titleMedium
                            ?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 16.0, // Fixed font size
                        ),
                      ),
                      const SizedBox(height: 8.0), // Fixed spacing
                      Wrap(
                        spacing: 8.0, // Fixed spacing
                        runSpacing: 8.0, // Fixed spacing
                        children: (template["tags"] as List).map((tag) {
                          return Chip(
                            label: Text(tag),
                            backgroundColor: AppTheme.lightTheme.colorScheme.secondaryContainer,
                            labelStyle: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onSecondaryContainer,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), // Fixed padding
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16.0), // Fixed spacing
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Use Template Button
          Padding(
            padding: const EdgeInsets.all(16.0), // Fixed padding
            child: SizedBox(
              width: double.infinity,
              height: 6.h, // Use h for button height
              child: ElevatedButton(
                onPressed: () => _useTemplate(template),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0), // Fixed border radius
                  ),
                ),
                child: Text(
                  'Use This Template',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
