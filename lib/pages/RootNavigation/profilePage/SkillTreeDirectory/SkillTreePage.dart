import 'package:flutter/material.dart';
import 'package:gravlift_workout_tracker_app/pages/RootNavigation/profilePage/SkillTreeDirectory/SkillTreeNode.dart';
import 'package:gravlift_workout_tracker_app/pages/templates/widgetsTemplates.dart';

//Globals
double? itemExtentVariable = 140;
bool showingNode = false;



class SkillTreePage extends StatefulWidget {
  const SkillTreePage({super.key, required this.skills, required this.mainSkillName});
  final List<SkillTreeNode> skills;
  final String mainSkillName;

  @override
  State<SkillTreePage> createState() => SkillTreePageState();
}

class SkillTreePageState extends State<SkillTreePage> {

  double? nodeSpacerWidth = 30;

  late List<SkillTreeNode> skills = widget.skills;
  late String mainSkillName = widget.mainSkillName;

  //Calculate the indexes of the nodes that have variants, for the painter.
  List<int> calculateVariantIndexes(List<SkillTreeNode> invertedNodesList){
    List<int> result = [];

    for(int i = 0;i<invertedNodesList.length;i++){
      if(invertedNodesList[i].variant != null){
        result.add(i);
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    // Reverse it so the first is the last one
    final nodes = skills.reversed.toList();

    return Scaffold(
      backgroundColor: Colors.grey[950],
      appBar: AppBar(
        title: Text(mainSkillName),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const Text("🏁 END", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25)),
            SizedBox(height: (itemExtentVariable! / 2)),

            Center(
              child: SizedBox(
                width: 320, // Everything's width to contain every node
                child: CustomPaint(
                  // Painter draws UNDER its children widgets.
                  painter: SkillTreePainter(nodeCount: nodes.length, variantIndexes: calculateVariantIndexes(nodes)),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: nodes.length,
                    itemExtent: itemExtentVariable, //FIXED HEIGHT
                    itemBuilder: (context, index) {
                      final node = nodes[index];

                      MainAxisAlignment mainAxis = MainAxisAlignment.center;
                      //Alignment ZIG-ZAG + variants on the right or left depending on the position. Straight left/right line
                      if(index == skills.length-1){mainAxis = MainAxisAlignment.center;}
                      else if(index == 0){mainAxis = MainAxisAlignment.center;}
                      else if(index %2==0){mainAxis = MainAxisAlignment.end;}
                      else if(index %2!=0){mainAxis = MainAxisAlignment.start;}

                      Widget normalNodeWidget = buildNodeWidget(context: context, node: node, setState: ()=>setState((){}));
                      Widget? variantNodeWidget;

                      if(node.variant!=null){variantNodeWidget = buildNodeWidget(context: context, node: node.variant!, setState: ()=>setState((){}));}

                      //Throw them in here based on the alignment
                      List<Widget> nodesOrder = [];

                      //if normal node and not start/end...
                      if(variantNodeWidget == null || (index== 0 || index == skills.length-1)){
                        nodesOrder = [normalNodeWidget];
                      } else {
                        if(mainAxis == MainAxisAlignment.end){
                          nodesOrder = [variantNodeWidget, SizedBox(width: nodeSpacerWidth), normalNodeWidget];
                        }
                        else if( mainAxis == MainAxisAlignment.start){
                          nodesOrder = [normalNodeWidget, SizedBox(width: nodeSpacerWidth),variantNodeWidget];
                        }
                      }

                      return Column(
                        children: [
                        //this row contains the *node* and the *variant* on the same level, if exists for that node
                          Row(
                            mainAxisAlignment: mainAxis,
                            children: nodesOrder,
                          ),
                        ],
                      );

                    },
                  ),
                ),
              ),
            ),
            const Text("START", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25)),
          ],
        ),
      ),
    );
  }
}

class SkillTreePainter extends CustomPainter {
  final int nodeCount;
  final List<int> variantIndexes;
  SkillTreePainter({required this.nodeCount, required this.variantIndexes});

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

  @override
  void paint(Canvas canvas, Size size) { //Size = CustomPainter's child's total width

    //Note: all of the adjustments in the coords like -30, +20, +30... aren't calculates but it's the result of
    //check the outcome and fixing it everytime.

    Paint paint = Paint();
      paint.color = Colors.deepPurpleAccent.withOpacity(0.4);
      paint.strokeWidth = 5;
      paint.strokeCap = StrokeCap.round;
      paint.style = PaintingStyle.stroke;

    final path = Path();
    double width = size.width;

    double calculateX(int index){
      if(index == 0 || index == nodeCount-1) return width/2;
      else if(index %2!=0)return (width/2) - 125; //Left
      else if(index %2==0)return (width/2)  + 120; //right

      return 0;
    }
    //moveTo points the "pen" certain coordinates but doesn't DRAW yet!
    path.moveTo(calculateX(0), (itemExtentVariable! / 2) - 30); //i=0 v

    double calculateVariantX(int index){
      //can't be start/end node.

      //if the its normal node is on the left, return spacer's width on the right and vice versa
      if(index %2!=0) return ((width/2) - 125) + 180;           //Left -> left + spacer
      else if(index %2==0)return ((width/2)  + 120) - 180;      //right -> right - spacer

      return 0;
    }

    //For every node
    for(int i = 1; i<nodeCount; i++){ //i=1
      double y = ((itemExtentVariable! * i) + itemExtentVariable! / 2) - 30;
      //lineTo DRAWS from the coords where the pen was, to new coordinates, every time.
      path.lineTo(calculateX(i), y);

      //If the current node we're in has a variant, draw the variant line, come back, and go onto the next one.
      if(variantIndexes.contains(i)){
        path.lineTo(calculateVariantX(i), y);
      }

      //Return to the original node position to move onto next one
      path.lineTo(calculateX(i), y);

    }

    canvas.drawPath(path, paint);
  }
}

Widget buildNodeWidget({required BuildContext context, required SkillTreeNode node, required VoidCallback setState}){

  //Using overlayPortal to show its child when overlayPortal.show is called through its controller.
  //>To make a widget attach to a certain position no matter the scrolling use [...]

  OverlayPortalController portalController = OverlayPortalController();
  LayerLink layerLink = LayerLink();

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: OverlayPortal(
      controller: portalController,
      //Child builder that shows the popup with skill information
      overlayChildBuilder: (BuildContext context) {
        return CompositedTransformFollower(
          link: layerLink,

          child: Align(
            alignment: AlignmentGeometry.center,
            child: Container(
              width: 250,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.deepPurpleAccent, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titolo Skill
                  Text(
                    node.name,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  //FUll image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      node.img_path,
                      height: 130,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // How To
                   Text(
                    node.how_to,
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                   Text(
                    "-Requirements:\n${node.requirements}",
                    style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: (){portalController.hide(); showingNode = false;},
                        child: const Text("Close", style: TextStyle(color: Colors.grey)),
                      ),
                      if (!node.isUnlocked)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurpleAccent),
                          onPressed: () {
                            node.isUnlocked = true;
                            showingNode = false;
                            setState();
                            portalController.hide();
                          },
                          child: const Text("Unlock"),
                        ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
      child: GestureDetector(
        onTap: (){
          //prevent from stacking overlays on top of eachother
          if(showingNode == true){
            return null;
          }
          print("Clicked on GestureDetector. Showing CompositedTransformFollower.");
          portalController.show();
          showingNode = true;
        },
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: node.isUnlocked ? Colors.deepPurpleAccent : Colors.grey[800],
            border: Border.all(
              color: node.isUnlocked ? Colors.white : Colors.white24,
              width: 3,
            ),
            boxShadow: [
              if (node.isUnlocked)
                BoxShadow(
                  color: Colors.deepPurpleAccent.withOpacity(0.5),
                  blurRadius: 12,
                  spreadRadius: 2,
                )
            ],
          ),
          child: Center(
            child: node.isUnlocked
                ? ClipOval( //So the images stays a circle since its a box
              child: SizedBox(
                width: 74,
                height: 74,
                child: Image.asset(
                  node.img_path,
                  fit: BoxFit.cover,
                ),
              ),
            )
                : const Icon(
              Icons.lock,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
      ),
    )
  );
}