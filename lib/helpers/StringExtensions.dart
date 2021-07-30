import 'dart:core';

extension StringExtension on String
{
  int getDigitCount()
  {
    if (this != null && this.length > 0)
    {
      final digits = RegExp(r'(\d{1})');
      return digits.allMatches(this).length;
    }
    else
      return 0;
  }

  String replaceChar(int index, String value)
  {
    var text = this;
    if(text != null && this.length >= index)
    {
      if(text[index] != value)
      {
        var nextCharIndex = index + 1;
        text = text.substring(0, index) + value + text.substring(nextCharIndex, text.length);
      }
    }
    return text;
  }

  int characterOccurs(String checkFor)
  {
    var count = 0;
    if(this != null)
    {
      for(var i = 0; i < this.length; i++)
      {
        if(this[i] == checkFor)
          count++;
      }
    }
    return count;
  }
}