import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'services/monkeymax_api.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MonkeyMaxApp());
}

class MonkeyMaxApp extends StatelessWidget {
  const MonkeyMaxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monkeymax',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF8B5CF6),
          secondary: const Color(0xFF22D3EE),
          surface: const Color(0xFF111827),
          background: const Color(0xFF0F172A),
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController(text: 'Aman');
  String _focus = 'Exam prep';
  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  late final Animation<double> _fade = CurvedAnimation(
    parent: _animationController,
    curve: Curves.easeOut,
  );

  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.12),
    end: Offset.zero,
  ).animate(
    CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ),
  );

  @override
  void dispose() {
    _nameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _continueToApp() {
    final name = _nameController.text.trim().isEmpty ? 'Scholar' : _nameController.text.trim();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (_, animation, __) => AppShell(userName: name, focus: _focus),
        transitionDuration: const Duration(milliseconds: 450),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0D14),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 34, 28, 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 680),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8B5CF6), Color(0xFF22D3EE)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.smart_toy_rounded, size: 26),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'MONKEYMAX',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 54),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF242047), Color(0xFF102F42)],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'YOUR AI STUDY COMPANION',
                              style: TextStyle(
                                color: Color(0xFFC4B5FD),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          const Text(
                            'Study smarter.\nShow up ready.',
                            style: TextStyle(
                              fontSize: 38,
                              height: 1.08,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Turn your notes into a clear plan, practice the right topics, and build momentum every day.',
                            style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.45),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: const [
                              _WelcomeFeature(icon: Icons.auto_awesome_rounded, text: 'Personalised'),
                              SizedBox(width: 14),
                              _WelcomeFeature(icon: Icons.insights_rounded, text: 'Adaptive'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: 'What should we call you?',
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                        filled: true,
                        fillColor: const Color(0xFF151925),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text('What are you working on?', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['Exam prep', 'Daily study', 'Quiz practice'].map((option) {
                        return ChoiceChip(
                          label: Text(option),
                          selected: _focus == option,
                          onSelected: (_) => setState(() => _focus = option),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 36),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: _continueToApp,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                        child: const Text('Continue as guest', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: _continueToApp,
                        child: const Text('I already have a study plan'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WelcomeFeature extends StatelessWidget {
  final IconData icon;
  final String text;

  const _WelcomeFeature({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF67E8F9)),
          const SizedBox(width: 6),
          Flexible(child: Text(text, style: const TextStyle(color: Colors.white70))),
        ],
      ),
    );
  }
}

class AppShell extends StatelessWidget {
  final String userName;
  final String focus;

  const AppShell({super.key, this.userName = 'Aman', this.focus = 'Exam prep'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111214),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 700) {
            return _MobileWorkspace(userName: userName, focus: focus);
          }

          return SafeArea(
            child: Row(
              children: [
                _ServerRail(),
                _ChannelSidebar(),
                Expanded(
                  child: Container(
                    color: const Color(0xFF1E1F22),
                    child: _MainWorkspace(userName: userName, focus: focus),
                  ),
                ),
                _RightPanel(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MobileWorkspace extends StatefulWidget {
  final String userName;
  final String focus;

  const _MobileWorkspace({required this.userName, required this.focus});

  @override
  State<_MobileWorkspace> createState() => _MobileWorkspaceState();
}

class _MobileWorkspaceState extends State<_MobileWorkspace>
    with SingleTickerProviderStateMixin {
  final MonkeymaxApi _api = MonkeymaxApi();
  final TextEditingController _noteController = TextEditingController();
  late final AnimationController _profileAnimation = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
  )..repeat();
  final List<String> _notes = [];
  int _points = 1250;
  final List<_TaskData> _tasks = [
    _TaskData(title: 'Review core concepts', timing: '25 min', done: true),
    _TaskData(title: 'Active recall quiz', timing: '20 min'),
    _TaskData(title: 'Write your error log', timing: '15 min'),
  ];
  int _tab = 0;
  bool _loading = false;
  String _status = 'Your plan is ready for today';

  @override
  void dispose() {
    _noteController.dispose();
    _profileAnimation.dispose();
    super.dispose();
  }

  Future<void> _scanMaterial() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'txt', 'doc', 'docx'],
    );
    if (!mounted || result == null || result.files.isEmpty) return;
    setState(() {
      _points += 25;
      _status = '${result.files.first.name} added to your study space';
    });
  }

  void _saveNote() {
    final note = _noteController.text.trim();
    if (note.isEmpty) return;
    setState(() {
      _notes.insert(0, note);
      _noteController.clear();
      _points += 10;
    });
  }

  Future<void> _generatePlan() async {
    setState(() {
      _loading = true;
      _status = 'Creating your personalised plan...';
    });
    try {
      final result = await _api.generatePlan(topic: widget.focus);
      if (!mounted) return;
      setState(() {
        _tasks
          ..clear()
          ..addAll(result.days.take(3).map((day) => _TaskData(
                title: 'Day ${day.day}: ${day.title}',
                timing: '${day.tasks.length * 15} min',
              )));
        _status = result.source == 'gemini' ? 'AI plan updated' : 'Offline plan updated';
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _status = 'Using your saved offline plan';
        _loading = false;
      });
    }
  }

  Widget _home() {
    final completed = _tasks.where((task) => task.done).length;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('MONKEYMAX', style: TextStyle(color: Color(0xFF67E8F9), fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.4)),
                  const SizedBox(height: 6),
                  Text('Hi, ${widget.userName}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFF8B5CF6),
              child: Text(widget.userName.characters.first.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF6D3BEA), Color(0xFF0891B2)]),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded, size: 18),
                  const SizedBox(width: 8),
                  Text(widget.focus, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 14),
              const Text('Make today count.', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(_status, style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: _loading ? null : _generatePlan,
                  icon: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.play_arrow_rounded),
                  label: Text(_loading ? 'Working...' : 'Build my plan'),
                  style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF172033)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(child: _MobileMetric(label: 'Progress', value: '${((completed / _tasks.length) * 100).round()}%', icon: Icons.track_changes_rounded, color: const Color(0xFF22D3EE))),
            const SizedBox(width: 12),
            const Expanded(child: _MobileMetric(label: 'Streak', value: '12 days', icon: Icons.local_fire_department_rounded, color: Color(0xFFF59E0B))),
          ],
        ),
        const SizedBox(height: 26),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Today\'s focus', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            TextButton(onPressed: () => setState(() => _tab = 1), child: const Text('See plan')),
          ],
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _scanMaterial,
          icon: const Icon(Icons.picture_as_pdf_rounded),
          label: const Text('Import notes or PDF'),
        ),
        const SizedBox(height: 10),
        ..._tasks.map((task) => _TaskRow(
              title: task.title,
              timing: task.timing,
              done: task.done,
              onTap: () => setState(() {
                task.done = !task.done;
                if (task.done) _points += 15;
              }),
            )),
      ],
    );
  }

  Widget _plan() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      children: [
        const Text('Your study plan', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text(widget.focus, style: const TextStyle(color: Colors.white60)),
        const SizedBox(height: 22),
        ..._tasks.asMap().entries.map((entry) => _PlanStep(index: entry.key + 1, task: entry.value)),
        const SizedBox(height: 16),
        const Text('The plan adapts as you complete tasks. Mark each step done to keep your progress honest.', style: TextStyle(color: Colors.white60, height: 1.4)),
      ],
    );
  }

  Widget _quiz() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      children: [
        const Text('Quiz room', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        const Text('Quick recall for your weakest topic', style: TextStyle(color: Colors.white60)),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: const Color(0xFF111827), borderRadius: BorderRadius.circular(22)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('QUESTION 1 OF 5', style: TextStyle(color: Color(0xFF67E8F9), fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1)),
              const SizedBox(height: 16),
              const Text('What helps a concept stick for longer?', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
              const SizedBox(height: 20),
              ...['Passive rereading', 'Active recall and error review', 'Skipping difficult topics'].map((answer) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: OutlinedButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(answer == 'Active recall and error review' ? 'Correct. Keep going.' : 'Review this idea and try again.'))), child: Align(alignment: Alignment.centerLeft, child: Text(answer))),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _notesPage() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      children: [
        const Text('Notes', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        const Text('Keep the ideas you want to remember.', style: TextStyle(color: Colors.white60)),
        const SizedBox(height: 20),
        TextField(
          controller: _noteController,
          minLines: 4,
          maxLines: 7,
          decoration: InputDecoration(
            hintText: 'Write a quick note or paste a key idea...',
            filled: true,
            fillColor: const Color(0xFF111827),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(onPressed: _saveNote, icon: const Icon(Icons.save_rounded), label: const Text('Save note')),
        const SizedBox(height: 22),
        if (_notes.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('Your saved notes will appear here.', style: TextStyle(color: Colors.white60))))
        else
          ..._notes.map((note) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFF111827), borderRadius: BorderRadius.circular(16)),
                child: Text(note, style: const TextStyle(height: 1.4)),
              )),
      ],
    );
  }

  Widget _profile() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      children: [
        const Text('Profile', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
        const SizedBox(height: 22),
        AnimatedBuilder(
          animation: _profileAnimation,
          builder: (context, child) => Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-1 + _profileAnimation.value * 2, -1),
                end: Alignment(1, 1 - _profileAnimation.value * 2),
                colors: const [Color(0xFF6D28D9), Color(0xFF0891B2), Color(0xFF111827)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: child,
          ),
          child: Column(
            children: [
              CircleAvatar(radius: 38, backgroundColor: Colors.white24, child: Text(widget.userName.substring(0, 1).toUpperCase(), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800))),
              const SizedBox(height: 12),
              Text(widget.userName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(widget.focus, style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const _ProfileRow(icon: Icons.local_fire_department_rounded, label: 'Current streak', value: '12 days'),
        _ProfileRow(icon: Icons.bolt_rounded, label: 'Monkey points', value: '$_points MP'),
        const _ProfileRow(icon: Icons.check_circle_outline_rounded, label: 'Tasks completed', value: '24'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [_home(), _plan(), _quiz(), _notesPage(), _profile()];
    return Scaffold(
      backgroundColor: const Color(0xFF0B0D14),
      body: SafeArea(child: pages[_tab]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        backgroundColor: const Color(0xFF111827),
        indicatorColor: const Color(0xFF35245E),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.calendar_today_outlined), selectedIcon: Icon(Icons.calendar_today_rounded), label: 'Plan'),
          NavigationDestination(icon: Icon(Icons.quiz_outlined), selectedIcon: Icon(Icons.quiz_rounded), label: 'Quiz'),
          NavigationDestination(icon: Icon(Icons.note_alt_outlined), selectedIcon: Icon(Icons.note_alt_rounded), label: 'Notes'),
          NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}

class _MobileMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MobileMetric({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF111827), borderRadius: BorderRadius.circular(18)),
      child: Row(children: [Icon(icon, color: color), const SizedBox(width: 10), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)), const SizedBox(height: 3), Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color))])]),
    );
  }
}

class _PlanStep extends StatelessWidget {
  final int index;
  final _TaskData task;

  const _PlanStep({required this.index, required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF111827), borderRadius: BorderRadius.circular(18)),
      child: Row(children: [Container(width: 34, height: 34, alignment: Alignment.center, decoration: BoxDecoration(color: task.done ? const Color(0xFF22C55E) : const Color(0xFF252B3A), shape: BoxShape.circle), child: task.done ? const Icon(Icons.check, size: 18) : Text('$index', style: const TextStyle(fontWeight: FontWeight.w800))), const SizedBox(width: 12), Expanded(child: Text(task.title, style: const TextStyle(fontWeight: FontWeight.w700))), Text(task.timing, style: const TextStyle(color: Colors.white60))]),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF111827), borderRadius: BorderRadius.circular(16)), child: Row(children: [Icon(icon, color: const Color(0xFF67E8F9)), const SizedBox(width: 12), Expanded(child: Text(label)), Text(value, style: const TextStyle(fontWeight: FontWeight.w800))]));
  }
}

class _ServerRail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final servers = [
      Icons.school_rounded,
      Icons.quiz_rounded,
      Icons.trending_up_rounded,
      Icons.auto_awesome_rounded,
    ];

    return Container(
      width: 80,
      color: const Color(0xFF1B1C20),
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF22D3EE)],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.smart_toy_rounded, size: 28),
          ),
          const SizedBox(height: 18),
          ...servers.map((icon) {
            final active = icon == Icons.school_rounded;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: active ? const Color(0xFF5865F2) : const Color(0xFF2B2D31),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
            );
          }),
          const Spacer(),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF2B2D31),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.person_rounded, size: 24),
          ),
        ],
      ),
    );
  }
}

class _ChannelSidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final channels = [
      _SidebarItem(title: '# 01-thermodynamics', active: true, status: 'online'),
      _SidebarItem(title: '# 02-organic-chem', active: false, status: 'pending'),
      _SidebarItem(title: '# 03-grammar', active: false, status: 'done'),
      _SidebarItem(title: '# 04-revision', active: false, status: 'warning'),
      _SidebarItem(title: '# 05-mock-test', active: false, status: 'online'),
    ];

    return Container(
      width: 280,
      color: const Color(0xFF1E1F22),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFF8B5CF6),
                child: Icon(Icons.person, size: 20),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Aman', style: TextStyle(fontWeight: FontWeight.w700)),
                  Text('Scholar#0421', style: TextStyle(color: Colors.white60, fontSize: 12)),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2937),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text('LVL 14', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('XP', style: TextStyle(fontSize: 12, color: Colors.white60)),
                    Text('2,400 / 3,000', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: const LinearProgressIndicator(
                    minHeight: 8,
                    value: 0.8,
                    backgroundColor: Color(0xFF1F2937),
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text('Study plan', style: TextStyle(fontSize: 12, color: Colors.white60, letterSpacing: 1.2)),
          const SizedBox(height: 10),
          ...channels.map(
            (item) => InkWell(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${item.title.replaceFirst('# ', '')} selected')),
              ),
              borderRadius: BorderRadius.circular(12),
              child: item,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: const [
                Icon(Icons.monetization_on_rounded, color: Color(0xFFFBBF24)),
                SizedBox(width: 8),
                Text('1,250 MP', style: TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final String title;
  final bool active;
  final String status;

  const _SidebarItem({
    required this.title,
    required this.active,
    required this.status,
  });

  Color get _statusColor {
    switch (status) {
      case 'done':
        return const Color(0xFF22C55E);
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'warning':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF22C55E);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF2B2D31) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: active ? Colors.white : Colors.white70,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MainWorkspace extends StatefulWidget {
  final String userName;
  final String focus;

  const _MainWorkspace({required this.userName, required this.focus});

  @override
  State<_MainWorkspace> createState() => _MainWorkspaceState();
}

class _MainWorkspaceState extends State<_MainWorkspace> {
  final MonkeymaxApi _api = MonkeymaxApi();
  bool _isGenerating = false;
  String _planStatus = 'Ready to build your plan';
  final List<_TaskData> _tasks = [
    _TaskData(title: 'Biology recap', timing: '45 mins', done: true),
    _TaskData(title: 'Math practice set', timing: '30 mins'),
    _TaskData(title: 'Grammar quick test', timing: '25 mins'),
  ];

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _showSearch() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search study plan'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Search topics or tasks'),
          onSubmitted: (value) {
            Navigator.pop(context);
            _showMessage(value.trim().isEmpty ? 'Type something to search.' : 'Searching for "$value"');
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ],
      ),
    );
  }

  Future<void> _startPlan() async {
    setState(() {
      _isGenerating = true;
      _planStatus = 'Building your ${widget.focus.toLowerCase()} plan...';
    });

    try {
      final generated = await _api.generatePlan(topic: widget.focus);
      if (!mounted) return;
      setState(() {
        _tasks
          ..clear()
          ..addAll(generated.days.take(3).map(
                (day) => _TaskData(
                  title: 'Day ${day.day}: ${day.title}',
                  timing: '${day.tasks.length * 15} mins',
                ),
              ));
        _planStatus = generated.source == 'gemini'
            ? 'AI plan ready for ${widget.focus}'
            : 'Offline plan ready for ${widget.focus}';
        _isGenerating = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _planStatus = 'Offline plan ready. Connect the backend for Gemini generation.';
        _isGenerating = false;
      });
    }
  }

  Future<void> _uploadMaterial() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'txt', 'doc', 'docx'],
    );
    if (!mounted || result == null || result.files.isEmpty) return;
    _showMessage('${result.files.first.name} added to your study plan.');
  }

  Widget _tasksPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${widget.focus} tasks', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        ..._tasks.map(
          (task) => _TaskRow(
            title: task.title,
            timing: task.timing,
            done: task.done,
            onTap: () => setState(() => task.done = !task.done),
          ),
        ),
        const SizedBox(height: 18),
        const Text('Quiz room', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Q3 / 10', style: TextStyle(color: Colors.white60)),
              SizedBox(height: 8),
              Text('Which process increases revision retention the most?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              SizedBox(height: 14),
              Text('A. passive rereading'),
              Text('B. active recall + error review'),
              Text('C. memorising the chapter summary'),
              Text('D. studying only the night before'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _planPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Plan preview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        const _MiniPlanCard(label: 'Day 1', title: 'Algebra fundamentals', status: 'Ready'),
        const _MiniPlanCard(label: 'Day 2', title: 'Past paper drills', status: 'Active'),
        const _MiniPlanCard(label: 'Day 3', title: 'Error log review', status: 'Queued'),
        const SizedBox(height: 18),
        const Text('Adaptive advice', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Text(
            'You are slightly behind schedule. Add a 20-minute recap block and finish one quick quiz before the next exam session.',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Good morning, ${widget.userName}',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  onPressed: () => _showMessage('You are all caught up for now.'),
                  icon: const Icon(Icons.notifications_none_rounded),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _showSearch,
                  icon: const Icon(Icons.search_rounded),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFF0EA5E9)],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('AI study plan', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        SizedBox(height: 8),
                        Text(
                          'Your personalised revision engine is ready.',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  FilledButton(
                    onPressed: _isGenerating ? null : _startPlan,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF111827),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    ),
                    child: _isGenerating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Start plan'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text(_planStatus, style: const TextStyle(color: Colors.white60)),
            const SizedBox(height: 12),
            Row(
              children: const [
                Expanded(child: _StatCard(label: 'Study hours', value: '14.5h', accent: Color(0xFF8B5CF6))),
                SizedBox(width: 14),
                Expanded(child: _StatCard(label: 'Quiz score', value: '86%', accent: Color(0xFF22D3EE))),
                SizedBox(width: 14),
                Expanded(child: _StatCard(label: 'Streak', value: '12 days', accent: Color(0xFFF59E0B))),
              ],
            ),
            const SizedBox(height: 22),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 700) {
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _tasksPanel(),
                          const SizedBox(height: 24),
                          _planPanel(),
                        ],
                      ),
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _tasksPanel()),
                      const SizedBox(width: 18),
                      Expanded(child: _planPanel()),
                    ],
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

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;

  const _StatCard({
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: accent)),
        ],
      ),
    );
  }
}

class _TaskData {
  final String title;
  final String timing;
  bool done;

  _TaskData({required this.title, required this.timing, this.done = false});
}

class _TaskRow extends StatelessWidget {
  final String title;
  final String timing;
  final bool done;
  final VoidCallback onTap;

  const _TaskRow({
    required this.title,
    required this.timing,
    required this.done,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: done ? const Color(0xFF22C55E) : const Color(0xFF1F2937),
                borderRadius: BorderRadius.circular(8),
              ),
              child: done ? const Icon(Icons.check, size: 16) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            Text(timing, style: const TextStyle(color: Colors.white60)),
          ],
        ),
      ),
    );
  }
}

class _MiniPlanCard extends StatelessWidget {
  final String label;
  final String title;
  final String status;

  const _MiniPlanCard({
    required this.label,
    required this.title,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            padding: const EdgeInsets.symmetric(vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(status, style: const TextStyle(color: Colors.white60, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RightPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: const Color(0xFF1B1C20),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('AI recap', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              'Past paper analysis suggests you need more practice on algebra word problems and grammar exceptions.',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          const SizedBox(height: 18),
          const Text('Weak areas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          ...[
            'Algebra',
            'Reading speed',
            'Biology diagrams',
          ].map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item),
                  const Text('64%', style: TextStyle(color: Color(0xFFF59E0B))),
                ],
              ),
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: () async {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['pdf', 'txt', 'doc', 'docx'],
              );
              if (!context.mounted || result == null || result.files.isEmpty) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${result.files.first.name} uploaded')),
              );
            },
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF22D3EE)],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                'Upload material and generate a custom plan',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
