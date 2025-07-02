import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'leaderboard_controller.dart';

class LeaderboardPage extends StatelessWidget {
  final LeaderboardController controller = Get.put(LeaderboardController());

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
              '👑 Bheek Ka King Board',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: 1.2,
              ),
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            tabs: [
              Tab(text: 'Top Bhikhari'),
              Tab(text: 'Top Donor'),
            ],
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Colors.grey,
          ),
        ),
        body: TabBarView(
          children: [
            // Top Bhikhari Tab
            Obx(() => _buildList(
                  context,
                  controller.leaders,
                  controller.currentUserPosition,
                  'Top 20 Bhikhari',
                  'total bheek',
                  Colors.green,
                )),
            // Top Donor Tab
            Obx(() => _buildList(
                  context,
                  controller.donors,
                  controller.currentUserDonorPosition,
                  'Top 20 Donor',
                  'total diya',
                  Colors.blue,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<Leader> list, int userPos, String title, String amountLabel, Color color) {
    return Column(
      children: [
        SizedBox(height: 8),
        Expanded(
          child: list.isEmpty
              ? Center(
                  child: Text(
                    'Koi data nahi mila!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final leader = list[index];
                    final isCurrentUser = leader.userId == controller.currentUserId.value;

                    // Medals for top 3
                    Widget leadingIcon;
                    if (index == 0) {
                      leadingIcon = Text('🥇', style: TextStyle(fontSize: 32));
                    } else if (index == 1) {
                      leadingIcon = Text('🥈', style: TextStyle(fontSize: 32));
                    } else if (index == 2) {
                      leadingIcon = Text('🥉', style: TextStyle(fontSize: 32));
                    } else {
                      leadingIcon = CircleAvatar(
                        backgroundColor: isCurrentUser ? color : Colors.grey[300],
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: isCurrentUser ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }

                    return Container(
                      decoration: BoxDecoration(
                        gradient: isCurrentUser
                            ? LinearGradient(
                                colors: [color.withOpacity(0.25), Colors.white],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : LinearGradient(
                                colors: [Colors.white, Colors.grey.shade100],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        leading: leadingIcon,
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                leader.name,
                                style: TextStyle(
                                  fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w600,
                                  color: isCurrentUser ? color : Colors.blueGrey.shade900,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            if (isCurrentUser)
                              Container(
                                margin: EdgeInsets.only(left: 8),
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'You',
                                  style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        subtitle: Row(
                          children: [
                            Icon(Icons.email, size: 14, color: Colors.grey[600]),
                            SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                leader.userId,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '₹${leader.amount}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: color,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              amountLabel,
                              style: TextStyle(
                                fontSize: 12,
                                color: color.withOpacity(0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      ),
                    );
                  },
                ),
        ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            userPos > 0
                ? 'Aapki Posiiton: $userPos'
                : 'Aap abhi Top 20 mein nahi ho!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}