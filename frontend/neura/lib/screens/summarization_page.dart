import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Please ensure you have added the following to your pubspec.yaml:
// dependencies:
//   google_generative_ai: ^latest_version
//   flutter_dotenv: ^latest_version
//
// And also added the assets folder to your pubspec.yaml:
// flutter:
//   assets:
//     - assets/

class SummarizationPage extends StatefulWidget {
  const SummarizationPage({super.key});

  @override
  State<SummarizationPage> createState() => _SummarizationPageState();
}

enum ContentState { summary, elaborate, links }

enum CurrentView { main, elaborate, links }

class _SummarizationPageState extends State<SummarizationPage>
    with SingleTickerProviderStateMixin {
  static const String _transcriptFilePath = 'assets/transcript.txt';

  String _transcriptText = '';
  String _summaryText = '';
  String _elaboratedText = '';
  String _linksText = '';
  bool _isLoading = true;
  bool _isMenuOpen = false;
  CurrentView _currentView = CurrentView.main;

  late final AnimationController _menuController;
  late final GenerativeModel _model;

  // Mock data for previous summaries
  final List<Map<String, dynamic>> _mockSummaries = [
    {'title': 'Q3 Performance Review', 'date': 'Oct 22'},
    {'title': 'Project Pegasus Kickoff', 'date': 'Oct 21'},
    {'title': 'Marketing Strategy 2024', 'date': 'Oct 20'},
    {'title': 'UX/UI Team Standup', 'date': 'Oct 19'},
  ];

  @override
  void initState() {
    super.initState();
    _menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _initModel();
    _loadTranscriptAndSummarize();
  }

  @override
  void dispose() {
    _menuController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      if (_isMenuOpen) {
        _menuController.forward();
      } else {
        _menuController.reverse();
      }
    });
  }

  void _initModel() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null) {
      _showError('GEMINI_API_KEY not found in .env file.');
      return;
    }
    _model = GenerativeModel(
        model: 'gemini-2.5-flash-preview-05-20', apiKey: apiKey);
  }

  Future<void> _loadTranscriptAndSummarize() async {
    try {
      final String fileContent =
          await rootBundle.loadString(_transcriptFilePath);
      _transcriptText = fileContent;
      await _getSummary();
    } catch (e) {
      _showError('Failed to load transcript: $e');
    }
  }

  void _showError(String message) {
    setState(() {
      _summaryText = 'Error: $message';
      _isLoading = false;
    });
  }

  Future<void> _getSummary() async {
    setState(() {
      _isLoading = true;
      _isMenuOpen = false;
      _menuController.reverse();
    });

    try {
      final String prompt =
          """Please provide a comprehensive summary of the following meeting transcript.
Break the summary into distinct, clear sections with headings:
- **Overview:** A high-level, concise summary of the entire meeting.
- **Key Points:** A bulleted list of the most important topics discussed.
- **Action Items:** A bulleted list of the decisions made or tasks assigned.
- **Conclusion:** A brief wrap-up of the meeting's outcome and next steps.

Please use the provided headings exactly as written.

Transcript:\n\n$_transcriptText""";

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      _summaryText = response.text ?? 'No summary available.';

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      _showError('Failed to generate summary: $e');
    }
  }

  Future<void> _getElaboratedSummary() async {
    if (_elaboratedText.isNotEmpty) {
      setState(() {
        _currentView = CurrentView.elaborate;
        _isMenuOpen = false;
        _menuController.reverse();
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _isMenuOpen = false;
      _menuController.reverse();
    });

    try {
      final String prompt =
          'Write a detailed, informative, and engaging blog post-style summary based on the following transcript. The summary should be well-structured and easy to read. Use headings and bullet points if appropriate.\n\n$_transcriptText';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      setState(() {
        _elaboratedText = response.text ?? 'No elaborated summary available.';
        _isLoading = false;
        _currentView = CurrentView.elaborate;
      });
    } catch (e) {
      _showError('Failed to generate elaborated summary: $e');
    }
  }

  Future<void> _getRelatedLinks() async {
    if (_linksText.isNotEmpty) {
      setState(() {
        _currentView = CurrentView.links;
        _isMenuOpen = false;
        _menuController.reverse();
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _isMenuOpen = false;
      _menuController.reverse();
    });

    try {
      final String prompt =
          'Based on the following transcript, provide a list of 5 related topics and suggested search terms. Format the response as a numbered list.\n\n$_transcriptText';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      setState(() {
        _linksText = response.text ?? 'No related links available.';
        _isLoading = false;
        _currentView = CurrentView.links;
      });
    } catch (e) {
      _showError('Failed to generate related links: $e');
    }
  }

  Widget _buildContent() {
    switch (_currentView) {
      case CurrentView.main:
        return _buildMainSummaryView();
      case CurrentView.elaborate:
        return _buildElaborateView();
      case CurrentView.links:
        return _buildLinksView();
    }
  }

  Widget _buildMainSummaryView() {
    return _buildSummaryCard(
      title: 'Meeting Summary',
      content: _summaryText,
    );
  }

  Widget _buildElaborateView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBackButton(),
        _buildContentCard(
          title: 'Elaborate Summary',
          content: _elaboratedText,
          gradient: LinearGradient(
            colors: [Colors.orange[700]!, Colors.deepOrange[900]!],
          ),
          icon: Icons.article_outlined,
        ),
      ],
    );
  }

  Widget _buildLinksView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBackButton(),
        _buildContentCard(
          title: 'Related Links',
          content: _linksText,
          gradient: LinearGradient(
            colors: [Colors.blue[700]!, Colors.indigo[900]!],
          ),
          icon: Icons.link_outlined,
        ),
      ],
    );
  }

  Widget _buildBackButton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () {
          setState(() {
            _currentView = CurrentView.main;
          });
        },
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String content,
  }) {
    List<TextSpan> _parseText(String text) {
      final List<TextSpan> spans = [];
      final lines = text.split('\n');
      for (var line in lines) {
        if (line.trim().startsWith('**') && line.trim().endsWith(':')) {
          final heading = line.replaceAll('**', '').replaceAll(':', '');
          spans.add(TextSpan(
            text: '\n$heading\n',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.lightBlueAccent,
                  fontWeight: FontWeight.bold,
                ),
          ));
        } else if (line.trim().startsWith('-')) {
          spans.add(TextSpan(
            text: '$line\n',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  height: 1.6,
                ),
          ));
        } else {
          spans.add(TextSpan(
            text: '$line\n',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                  height: 1.6,
                ),
          ));
        }
      }
      return spans;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2d2740), Color(0xFF140c21)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            RichText(
              text: TextSpan(
                children: _parseText(content),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentCard({
    required String title,
    required String content,
    required Gradient gradient,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 30, color: Colors.white),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              content.isEmpty ? 'Loading...' : content,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                    height: 1.6,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Summary',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              );
            },
          ),
        ],
      ),
      endDrawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey[900]!, Colors.deepPurple[900]!],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2d2740), Color(0xFF140c21)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Text(
                  'Previous Summaries',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                      ),
                ),
              ),
              ..._mockSummaries
                  .map((summary) => _buildPreviousSummaryCard(
                        summary['title'],
                        summary['date'],
                      ))
                  .toList(),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey[900]!, Colors.deepPurple[900]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white))
            : Padding(
                padding: EdgeInsets.all(isSmallScreen ? 16.0 : 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: _buildContent(),
                      ),
                    ),
                  ],
                ),
              ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_isMenuOpen) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: FloatingActionButton(
                heroTag: 'elaborate',
                onPressed: _getElaboratedSummary,
                tooltip: 'Elaborate Summary',
                backgroundColor: Colors.orange[700],
                child: const Icon(Icons.article_outlined, color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: FloatingActionButton(
                heroTag: 'links',
                onPressed: _getRelatedLinks,
                tooltip: 'Related Links',
                backgroundColor: Colors.blue[700],
                child: const Icon(Icons.link_outlined, color: Colors.white),
              ),
            ),
          ],
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'menu',
            onPressed: _toggleMenu,
            tooltip: 'Toggle Menu',
            child: AnimatedIcon(
              icon: AnimatedIcons.menu_close,
              progress: _menuController,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviousSummaryCard(String title, String date) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2d2740),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        title: Text(
          title,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          date,
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54),
        onTap: () {
          // TODO: Implement logic to load previous summary
        },
      ),
    );
  }
}
