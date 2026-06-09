import 'package:flutter/material.dart';

class QuestionReorder extends StatelessWidget {
  final Map<String, dynamic> currentQ;
  final List<String> reorderList;
  final bool isAnswered;
  final ValueChanged<List<String>> onReorderChanged;

  const QuestionReorder({
    super.key,
    required this.currentQ,
    required this.reorderList,
    required this.isAnswered,
    required this.onReorderChanged,
  });

  @override
  Widget build(BuildContext context) {
    final choices = currentQ['choices'] as List;
    final Map<String, String> idToText = {
      for (var choice in choices)
        (choice as Map<String, String>)['id']!: choice['text']!,
    };

    return Column(
      children: [
        const SizedBox(height: 8),
        const Text(
          '드래그해서 올바른 순서로 나열하세요',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF9CA3AF),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          currentQ['prompt'] as String,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
            height: 26 / 18,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        Theme(
          data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
          child: ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            onReorder: (int oldIndex, int newIndex) {
              if (isAnswered) return;
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              final newList = List<String>.from(reorderList);
              final String item = newList.removeAt(oldIndex);
              newList.insert(newIndex, item);
              onReorderChanged(newList);
            },
            children: [
              for (int i = 0; i < reorderList.length; i++)
                Container(
                  key: ValueKey(reorderList[i]),
                  margin: const EdgeInsets.only(bottom: 12.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFFD0D5E0),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
                    child: Row(
                      children: [
                        ReorderableDragStartListener(
                          index: i,
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            color: Colors.transparent,
                            child: const Text(
                              '⠿',
                              style: TextStyle(
                                fontFamily: 'Noto Sans KR',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            idToText[reorderList[i]] ?? '',
                            style: const TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                              height: 16 / 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
