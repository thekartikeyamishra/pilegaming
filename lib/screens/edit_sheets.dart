import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/game.dart';
import '../services/store.dart';
import '../services/toolbox.dart';
import '../theme.dart';

class EditSheets {
  static const platforms = ['PC', 'PS5', 'PS4', 'Xbox', 'Switch', 'Mobile', 'Other'];

  static Future<void> editGame(BuildContext context, GameEntry? existing) async {
    final store = PileStore.instance;
    final g = existing ??
        GameEntry(
            id: DateTime.now().millisecondsSinceEpoch.toString(), title: '');
    final title = TextEditingController(text: g.title);
    final price = TextEditingController(
        text: g.pricePaid == 0 ? '' : g.pricePaid.toStringAsFixed(0));
    final hours = TextEditingController(
        text: g.hoursPlayed == 0 ? '' : g.hoursPlayed.toStringAsFixed(0));

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: PlColors.void_,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(existing == null ? 'ADD GAME' : 'EDIT GAME',
                    style: Theme.of(ctx).textTheme.labelSmall),
                const SizedBox(height: 12),
                TextField(
                    controller: title,
                    autofocus: existing == null,
                    decoration:
                        const InputDecoration(labelText: 'Title')),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: platforms.map((p) {
                    final sel = g.platform == p;
                    return ChoiceChip(
                      label: Text(p),
                      selected: sel,
                      showCheckmark: false,
                      selectedColor: PlColors.lime,
                      backgroundColor: PlColors.panel,
                      side: const BorderSide(color: PlColors.line),
                      labelStyle: TextStyle(
                          color: sel ? PlColors.void_ : PlColors.dim,
                          fontWeight: FontWeight.w600),
                      onSelected: (_) => setSheet(() => g.platform = p),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: GameStatus.values.map((s) {
                    final sel = g.status == s;
                    return ChoiceChip(
                      label: Text(s.label),
                      selected: sel,
                      showCheckmark: false,
                      selectedColor: PlColors.magenta,
                      backgroundColor: PlColors.panel,
                      side: const BorderSide(color: PlColors.line),
                      labelStyle: TextStyle(
                          color: sel ? PlColors.void_ : PlColors.dim,
                          fontWeight: FontWeight.w600),
                      onSelected: (_) => setSheet(() => g.status = s),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                      child: TextField(
                          controller: price,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'Price paid (\$)'))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: TextField(
                          controller: hours,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'Hours played'))),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Text('Rating  ',
                      style: Theme.of(ctx).textTheme.bodySmall),
                  ...List.generate(5, (i) {
                    return IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                          i < g.rating ? Icons.star : Icons.star_border,
                          color: PlColors.amber,
                          size: 26),
                      onPressed: () => setSheet(
                          () => g.rating = (g.rating == i + 1) ? 0 : i + 1),
                    );
                  }),
                ]),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () async {
                    g.title = title.text.trim().isEmpty
                        ? 'Untitled'
                        : title.text.trim();
                    g.pricePaid =
                        double.tryParse(price.text.replaceAll(',', '')) ?? 0;
                    g.hoursPlayed =
                        double.tryParse(hours.text.replaceAll(',', '')) ?? 0;
                    if (existing == null) {
                      await store.addGame(g);
                    } else {
                      await store.persist();
                    }
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: Text(existing == null ? 'Add to pile' : 'Save'),
                ),
                if (existing != null) ...[
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () async {
                      await store.deleteGame(g.id);
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: const Text('Delete',
                        style: TextStyle(color: PlColors.red)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Future<void> editHype(BuildContext context, HypeEntry? existing) async {
    final store = PileStore.instance;
    final h = existing ??
        HypeEntry(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: '',
          releaseDate: DateTime.now().add(const Duration(days: 90)),
        );
    final title = TextEditingController(text: h.title);
    final target = TextEditingController(
        text: h.targetPrice == 0 ? '' : h.targetPrice.toStringAsFixed(0));
    final saved = TextEditingController(
        text: h.saved == 0 ? '' : h.saved.toStringAsFixed(0));

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: PlColors.void_,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(existing == null ? 'TRACK A RELEASE' : 'EDIT RELEASE',
                  style: Theme.of(ctx).textTheme.labelSmall),
              const SizedBox(height: 12),
              TextField(
                  controller: title,
                  autofocus: existing == null,
                  decoration: const InputDecoration(
                      labelText: 'Game title (any game, any year)')),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  title: Text('Release date',
                      style: Theme.of(ctx).textTheme.bodyMedium),
                  trailing: Text(
                      DateFormat('MMM d, yyyy').format(h.releaseDate),
                      style: Theme.of(ctx)
                          .textTheme
                          .bodyMedium!
                          .copyWith(color: PlColors.magenta)),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: h.releaseDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2036),
                    );
                    if (picked != null) setSheet(() => h.releaseDate = picked);
                  },
                ),
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: TextField(
                        controller: target,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: 'Budget (\$)'))),
                const SizedBox(width: 12),
                Expanded(
                    child: TextField(
                        controller: saved,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: 'Saved so far (\$)'))),
              ]),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  h.title = title.text.trim().isEmpty
                      ? 'Untitled'
                      : title.text.trim();
                  h.targetPrice =
                      double.tryParse(target.text.replaceAll(',', '')) ?? 0;
                  h.saved =
                      double.tryParse(saved.text.replaceAll(',', '')) ?? 0;
                  if (existing == null) {
                    await store.addHype(h);
                  } else {
                    await store.persist();
                  }
                  await Notify.rescheduleAll();
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: Text(existing == null ? 'Start countdown' : 'Save'),
              ),
              if (existing != null) ...[
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () async {
                    await store.deleteHype(h.id);
                    await Notify.rescheduleAll();
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: const Text('Delete',
                      style: TextStyle(color: PlColors.red)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
