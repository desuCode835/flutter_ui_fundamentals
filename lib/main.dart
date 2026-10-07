import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'course_state.dart';
import 'models/course.dart';

void main() {
  runApp(
    ChangeNotifierProvider(create: (_) => CourseState(), child: const MyApp()),
  );
}

// ======================================================
// APP
// ======================================================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Course Explorer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ResponsiveShell(),
    );
  }
}

// ======================================================
// DATA COURSE
// ======================================================

const List<Course> courses = [
  Course(
    code: 'MOB04',
    title: 'Responsive Layout',
    credits: 3,
    status: 'Active',
  ),
  Course(code: 'MOB05', title: 'Navigation', credits: 3, status: 'Planned'),
  Course(code: 'MOB06', title: 'Interaction', credits: 3, status: 'Planned'),
  Course(
    code: 'MOB07',
    title: 'Form Validation',
    credits: 3,
    status: 'Planned',
  ),
  Course(code: 'MOB08', title: 'Feedback UI', credits: 3, status: 'Planned'),
  Course(code: 'MOB09', title: 'Mini Project', credits: 4, status: 'Active'),
];

// ======================================================
// RESPONSIVE SHELL
// ======================================================

class ResponsiveShell extends StatefulWidget {
  const ResponsiveShell({super.key});

  @override
  State<ResponsiveShell> createState() => _ResponsiveShellState();
}

class _ResponsiveShellState extends State<ResponsiveShell> {
  int selectedIndex = 0;

  final List<Widget> pages = const [HomePage(), CoursesPage(), ProfilePage()];

  NavigationBar buildNavigationBar() {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        setState(() {
          selectedIndex = index;
        });
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.book_outlined),
          selectedIcon: Icon(Icons.book),
          label: 'Courses',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  NavigationRail buildNavigationRail() {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        setState(() {
          selectedIndex = index;
        });
      },
      labelType: NavigationRailLabelType.all,
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: Text('Home'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.book_outlined),
          selectedIcon: Icon(Icons.book),
          label: Text('Courses'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: Text('Profile'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 840) {
          return Scaffold(
            body: pages[selectedIndex],
            bottomNavigationBar: buildNavigationBar(),
          );
        }

        return Scaffold(
          body: Row(
            children: [
              buildNavigationRail(),
              const VerticalDivider(width: 1),
              Expanded(child: pages[selectedIndex]),
            ],
          ),
        );
      },
    );
  }
}

// ======================================================
// HOME PAGE
// ======================================================

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Course Explorer')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            const Icon(Icons.school, size: 90),
            const SizedBox(height: 20),
            const Text(
              'Course Explorer',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Aplikasi untuk melihat daftar course '
              'dan informasi pembelajaran.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Identitas Mahasiswa',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text('Nama: Gede Supadma'),
                    Text('NIM: 2415051014'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Selamat datang di Course Explorer'),
                  ),
                );
              },
              icon: const Icon(Icons.info_outline),
              label: const Text('Tampilkan Info'),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// COURSES PAGE
// ======================================================

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  int getColumns(double width) {
    if (width < 600) {
      return 1;
    }

    if (width < 840) {
      return 2;
    }

    return 3;
  }

  double getAspectRatio(int columns) {
    if (columns == 1) {
      return 2.2;
    }

    if (columns == 2) {
      return 1.4;
    }

    return 1.3;
  }

  // ====================================================
  // BUKA DETAIL
  // ====================================================

  void openDetail(Course course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return CourseDetailPage(course: course);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Course Explorer')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Consumer<CourseState>(
              builder: (context, courseState, child) {
                return Text(
                  'Jumlah Favorite: ${courseState.favorites.length}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final columns = getColumns(constraints.maxWidth);

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: courses.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: getAspectRatio(columns),
                  ),
                  itemBuilder: (context, index) {
                    return CourseCard(
                      course: courses[index],
                      onOpenDetail: () {
                        openDetail(courses[index]);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// COURSE CARD
// ======================================================

class CourseCard extends StatelessWidget {
  final Course course;

  // Callback untuk membuka detail
  final VoidCallback onOpenDetail;

  const CourseCard({
    super.key,
    required this.course,
    required this.onOpenDetail,
  });

  @override
  Widget build(BuildContext context) {
    final courseState = context.watch<CourseState>();
    final isFavorite = courseState.favorites.contains(course.code);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onOpenDetail,
        onLongPress: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${course.title} - ${course.code}')),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          course.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          // Menggunakan context.read untuk memanggil aksi
                          context.read<CourseState>().toggleFavorite(
                            course.code,
                          );
                        },
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(course.code, style: const TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('${course.credits} SKS'),
                  const Spacer(),
                  Text(
                    course.status,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ======================================================
// COURSE DETAIL
// ======================================================

class CourseDetailPage extends StatelessWidget {
  final Course course;

  const CourseDetailPage({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final courseState = context.watch<CourseState>();
    final isFavorite = courseState.favorites.contains(course.code);

    return Scaffold(
      appBar: AppBar(title: const Text('Course Detail')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.book, size: 80),
            const SizedBox(height: 20),
            Text(
              course.title,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Kode: ${course.code}', style: const TextStyle(fontSize: 17)),
            Text(
              'SKS: ${course.credits}',
              style: const TextStyle(fontSize: 17),
            ),
            Text(
              'Status: ${course.status}',
              style: const TextStyle(fontSize: 17),
            ),
            const SizedBox(height: 30),
            const Text(
              'Mahasiswa',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text('Gede Supadma'),
            const Text('NIM: 2415051014'),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final isFav = context.read<CourseState>().favorites.contains(
                    course.code,
                  );
                  context.read<CourseState>().toggleFavorite(course.code);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        !isFav
                            ? 'Course ditambahkan ke favorite'
                            : 'Course dihapus dari favorite',
                      ),
                    ),
                  );
                },
                icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                label: Text(isFavorite ? 'Favorite' : 'Tambah Favorite'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// PROFILE PAGE
// ======================================================

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(radius: 45, child: Icon(Icons.person, size: 50)),
            const SizedBox(height: 12),
            const Text(
              'Gede Supadma',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text('NIM: 2415051014'),
            const SizedBox(height: 30),
            const FeedbackForm(),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// FEEDBACK FORM
// ======================================================

class FeedbackForm extends StatefulWidget {
  const FeedbackForm({super.key});

  @override
  State<FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  final formKey = GlobalKey<FormState>();

  final TextEditingController namaController = TextEditingController(
    text: 'Gede Supadma',
  );

  final TextEditingController nimController = TextEditingController(
    text: '2415051014',
  );

  final TextEditingController komentarController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    namaController.dispose();
    nimController.dispose();
    komentarController.dispose();
    super.dispose();
  }

  void submitFeedback() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text('Apakah Anda yakin ingin mengirim feedback?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                saveFeedback();
              },
              child: const Text('Kirim'),
            ),
          ],
        );
      },
    );
  }

  Future<void> saveFeedback() async {
    setState(() {
      isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Feedback berhasil disimpan')));
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Feedback',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: namaController,
            decoration: const InputDecoration(
              labelText: 'Nama',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Nama wajib diisi';
              }

              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: nimController,
            decoration: const InputDecoration(
              labelText: 'NIM',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.badge),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'NIM wajib diisi';
              }

              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: komentarController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Komentar',
              hintText: 'Minimal 5 karakter',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.comment),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Komentar wajib diisi';
              }

              if (value.trim().length < 5) {
                return 'Komentar minimal 5 karakter';
              }

              return null;
            },
          ),
          const SizedBox(height: 16),
          if (isLoading)
            const Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 8),
                Text('Menyimpan feedback...'),
              ],
            )
          else
            ElevatedButton.icon(
              onPressed: submitFeedback,
              icon: const Icon(Icons.send),
              label: const Text('Kirim Feedback'),
            ),
        ],
      ),
    );
  }
}
