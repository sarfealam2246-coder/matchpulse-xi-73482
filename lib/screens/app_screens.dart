import 'package:flutter/material.dart';
import '../services/supabase_api.dart';

class LoginOrEntryScreen extends StatefulWidget {
  final VoidCallback onAuthenticated;

  const LoginOrEntryScreen({Key? key, required this.onAuthenticated}) : super(key: key);

  @override
  _LoginOrEntryScreenState createState() => _LoginOrEntryScreenState();
}

class _LoginOrEntryScreenState extends State<LoginOrEntryScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isOtpSent = false;

  void _sendOtp() async {
    final email = _emailController.text;
    if (await SupabaseApi.sendEmailOtp(email)) {
      setState(() {
        _isOtpSent = true;
      });
    }
  }

  void _verifyOtp() async {
    final email = _emailController.text;
    final otp = _otpController.text;
    if (await SupabaseApi.verifyEmailOtp(email, otp)) {
      widget.onAuthenticated();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0B1120),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Card(
            color: Color(0xFF162032),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Login", style: TextStyle(color: Color(0xFFFFD700), fontSize: 24)),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: "Email"),
                  ),
                  if (_isOtpSent) ...[
                    TextField(
                      controller: _otpController,
                      decoration: InputDecoration(labelText: "OTP"),
                    ),
                    ElevatedButton(
                      onPressed: _verifyOtp,
                      child: Text("Verify OTP"),
                    ),
                  ] else ...[
                    ElevatedButton(
                      onPressed: _sendOtp,
                      child: Text("Send OTP"),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeDashboardScreen extends StatefulWidget {
  @override
  _HomeDashboardScreenState createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0B1120),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              color: Color(0xFF162032),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text("Player Name", style: TextStyle(color: Color(0xFFFFD700), fontSize: 20)),
                    Text("Rank Badge", style: TextStyle(color: Color(0xFFFFD700))),
                    Text("Virtual Coins: 100", style: TextStyle(color: Color(0xFFFFD700))),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text("+50 Daily Bonus"),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Container(
              height: 200,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _matchCard("IND vs AUS T20"),
                  _matchCard("MUM vs DEL League"),
                  _matchCard("BLR vs CHE Clash"),
                ],
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _actionButton("My Contests"),
                _actionButton("Live Polls"),
                _actionButton("Refer Squad"),
                _actionButton("App Guide"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _matchCard(String match) {
    return Card(
      color: Color(0xFF162032),
      child: InkWell(
        onTap: () {
          // Navigator.push to Prediction Entry
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(match, style: TextStyle(color: Color(0xFFFFD700))),
        ),
      ),
    );
  }

  Widget _actionButton(String label) {
    return ElevatedButton(
      onPressed: () {
        // Action based on label
      },
      child: Text(label),
    );
  }
}

class WorkspaceOrActionScreen extends StatefulWidget {
  @override
  _WorkspaceOrActionScreenState createState() => _WorkspaceOrActionScreenState();
}

class _WorkspaceOrActionScreenState extends State<WorkspaceOrActionScreen> {
  final TextEditingController _matchNameController = TextEditingController();
  final TextEditingController _pickedTeamController = TextEditingController();
  final TextEditingController _confidencePointsController = TextEditingController();

  void _createChallenge() async {
    final matchName = _matchNameController.text;
    final pickedTeam = _pickedTeamController.text;
    final confidencePoints = int.tryParse(_confidencePointsController.text) ?? 0;

    await SupabaseApi.saveItem("prediction", {
      "match_name": matchName,
      "picked_team": pickedTeam,
      "confidence_points": confidencePoints,
    });
    await SupabaseApi.recordTx();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0B1120),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _matchNameController,
              decoration: InputDecoration(labelText: "Match Name"),
            ),
            TextField(
              controller: _pickedTeamController,
              decoration: InputDecoration(labelText: "Picked Team"),
            ),
            TextField(
              controller: _confidencePointsController,
              decoration: InputDecoration(labelText: "Confidence Points (10-100)"),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: _createChallenge,
              child: Text("Create Squad Challenge"),
            ),
          ],
        ),
      ),
    );
  }
}

class RecordsOrRankScreen extends StatefulWidget {
  @override
  _RecordsOrRankScreenState createState() => _RecordsOrRankScreenState();
}

class _RecordsOrRankScreenState extends State<RecordsOrRankScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0B1120),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(labelText: "Search"),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 10, // Replace with actual data length
                itemBuilder: (context, index) {
                  return _recordCard("Prediction #$index");
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _recordCard(String title) {
    return Card(
      color: Color(0xFF162032),
      child: ListTile(
        title: Text(title, style: TextStyle(color: Color(0xFFFFD700))),
        onTap: () {
          // Navigator.push to Match Scorecard Detail Page
        },
      ),
    );
  }
}

class ProfileOrSettingsScreen extends StatefulWidget {
  @override
  _ProfileOrSettingsScreenState createState() => _ProfileOrSettingsScreenState();
}

class _ProfileOrSettingsScreenState extends State<ProfileOrSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0B1120),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Player Name", style: TextStyle(color: Color(0xFFFFD700))),
            Text("Email: player@example.com", style: TextStyle(color: Color(0xFFFFD700))),
            Text("Total Coins: 100", style: TextStyle(color: Color(0xFFFFD700))),
            ElevatedButton(
              onPressed: () {
                // Show Refer & Share Code dialog
              },
              child: Text("Refer & Share Code"),
            ),
            ElevatedButton(
              onPressed: () {
                // Show How to Play Tutorial
              },
              child: Text("How to Play Tutorial"),
            ),
            ElevatedButton(
              onPressed: () async {
                await SupabaseApi.logout();
                // Navigate to Login or Entry Screen
              },
              child: Text("Log Out"),
            ),
          ],
        ),
      ),
    );
  }
}