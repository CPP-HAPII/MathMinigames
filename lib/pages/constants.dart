import 'package:flutter/material.dart';

const darkStyle = TextStyle(color: Colors.white);
const lightStyle = TextStyle(color: Colors.black);

const ColorProfile lightFlavor = ColorProfile(
    backgroundColor: Colors.white,
    headerColor: Colors.lightBlue,
    buttonColor: Colors.blueGrey, 
    textColor: Colors.black,
    contrastTextColor: Colors.black,
    checkAnswerButtonColor: Colors.green,
    clearAnswerButtonColor: Colors.red,
    backBoxDecoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage("assets/images/blank.png"), 
        repeat: ImageRepeat.repeat,
        scale: 0.4
      )
    ),
    backgroundImage: AssetImage("assets/images/blank.png"),
    idKey: "light flavor"
  );

  const ColorProfile darkFlavor = ColorProfile(
    backgroundColor: Color.fromARGB(255, 0, 0, 0),
    headerColor: Color.fromARGB(255, 112, 112, 112),
    buttonColor: Colors.grey, 
    textColor: Color.fromARGB(255, 255, 255, 255),
    contrastTextColor: Color.fromARGB(255, 255, 255, 255),
    checkAnswerButtonColor: Colors.green,
    clearAnswerButtonColor: Colors.red,
    backBoxDecoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage("assets/images/blank.png"), 
        fit: BoxFit.cover,
        invertColors: true
      ),
      color: Color.fromARGB(255, 0, 0, 0),
    ),
    backgroundImage: AssetImage("assets/images/blank.png"),
    idKey: "dark flavor"
  );

const ColorProfile plainFlavor = ColorProfile(
    backgroundColor: Colors.white,
    headerColor: Color.fromARGB(255, 210, 210, 210),
    buttonColor: Color.fromARGB(255, 34, 61, 89), 
    textColor: Colors.white,
    contrastTextColor: Colors.white,
    checkAnswerButtonColor: Colors.green,
    clearAnswerButtonColor: Colors.red,
    backBoxDecoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage("assets/images/space.png"), 
        fit: BoxFit.cover
      ),
      color: Colors.white
    ),
    backgroundImage: AssetImage("assets/images/space.png"),
    idKey: "plain flavor"
  );

const ColorProfile mintFlavor = ColorProfile(
    backgroundColor: Color.fromARGB(255, 18, 165, 170),
    headerColor: Color.fromARGB(255, 60, 144, 163),
    buttonColor: Color.fromARGB(255, 38, 171, 171), 
    textColor: Colors.black,
    contrastTextColor: Colors.white,
    checkAnswerButtonColor: Colors.green,
    clearAnswerButtonColor: Colors.red,
    backBoxDecoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage("assets/images/mint_flavor.png"),
        fit: BoxFit.cover
      ),
      color: Color.fromARGB(255, 18, 165, 170),
    ),
    backgroundImage: AssetImage("assets/images/mint_flavor.png"),
    idKey: "mint flavor"
  );

const ColorProfile strawberryFlavor = ColorProfile(
    backgroundColor: Colors.white,
    headerColor: Color.fromARGB(255, 254, 129, 177),
    buttonColor: Color.fromARGB(255, 250, 135, 135), 
    textColor: Colors.white,
    contrastTextColor: Colors.black,
    checkAnswerButtonColor: Colors.green,
    clearAnswerButtonColor: Colors.red,
    backBoxDecoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage("assets/images/rad_red.png"), 
        fit: BoxFit.cover
      ),
      color: Color.fromARGB(255, 197, 81, 187),
    ),
    backgroundImage: AssetImage("assets/images/rad_red.png"),
    idKey: "strawberry flavor"
  );

const ColorProfile bananaFlavor = ColorProfile(
    backgroundColor: Colors.white,
    headerColor: Colors.yellow,
    buttonColor: Color.fromARGB(255, 237, 226, 9), 
    textColor: Colors.black,
    contrastTextColor: Colors.black,
    checkAnswerButtonColor: Colors.green,
    clearAnswerButtonColor: Colors.red,
    backBoxDecoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage("assets/images/yellow.png"), 
        fit: BoxFit.cover
      ),
      color: Color.fromARGB(255, 255, 251, 0),
    ),
    backgroundImage: AssetImage("assets/images/yellow.png"),
    idKey: "banana flavor"
  );

const ColorProfile peanutFlavor = ColorProfile(
    backgroundColor: Colors.white,
    headerColor: Color.fromARGB(255, 215, 129, 43),
    buttonColor: Color.fromARGB(255, 210, 139, 40), 
    textColor: Colors.black,
    contrastTextColor: Colors.white,
    checkAnswerButtonColor: Colors.green,
    clearAnswerButtonColor: Colors.red,
    backBoxDecoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage("assets/images/dreamy.png"), 
        fit: BoxFit.cover
      ),
      color: Color.fromARGB(255, 168, 98, 79),
    ),
    backgroundImage: AssetImage("assets/images/dreamy.png"),
    idKey: "peanut flavor"
  );

// Color profiles for the screens
class ColorProfile {
  const ColorProfile({
    required this.backgroundColor,
    required this.headerColor,
    required this.buttonColor,
    required this.textColor,
    required this.contrastTextColor,
    required this.checkAnswerButtonColor,
    required this.clearAnswerButtonColor,
    required this.backBoxDecoration,
    required this.backgroundImage,
    this.disabledButtonColor = Colors.grey,
    this.idKey = "color profile"
  });


  final String idKey;
  final Color backgroundColor;
  final Color headerColor;
  final Color buttonColor;
  final Color textColor;
  final Color contrastTextColor;
  final Color checkAnswerButtonColor;
  final Color clearAnswerButtonColor;
  final AssetImage backgroundImage;
  final BoxDecoration backBoxDecoration;
  final Color disabledButtonColor;
}