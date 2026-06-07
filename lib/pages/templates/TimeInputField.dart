//for ongoingWorkoutPage.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TimeInputField extends StatefulWidget {
  String hint;
  String uniqueKey;
  Function(int) onSave;

  TimeInputField({super.key, required this.hint, required this.uniqueKey, required this.onSave});

  @override
  State<StatefulWidget> createState() =>TimeInputFieldState();
}
class TimeInputFieldState extends State<TimeInputField> {

  late TextEditingController controller = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onSubmitted: (_){ //_ means not needed
        widget.onSave(int.tryParse(controller.text) ?? 0);
      },

      onTapOutside: (_){
        FocusScope.of(context).unfocus(); //get out of keyboard
        widget.onSave(int.tryParse(controller.text) ?? 0);
      },

      key: ValueKey("${widget.uniqueKey}-2"),
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w500),

      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        focusedBorder:
        UnderlineInputBorder(borderSide: BorderSide(color: Colors.deepPurpleAccent, width: 2)),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!)),
      ),
    );
  }

}