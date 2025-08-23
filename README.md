# apex
apex
CREATE OR REPLACE FUNCTION IPIHR.spel_out (a_number NUMBER)
   RETURN CHAR
IS
   TYPE numtab IS TABLE OF VARCHAR2 (30)
      INDEX BY BINARY_INTEGER;

   number_chart   numtab;
   crore          NUMBER;
   lakh           NUMBER;
   thou           NUMBER;
   hund           NUMBER;
   doubl          NUMBER;
   sing           NUMBER;
   deci           NUMBER;
   text           VARCHAR2 (500);
BEGIN
   --The Table
   number_chart (1) := 'One';
   number_chart (2) := 'Two';
   number_chart (3) := 'Three';
   number_chart (4) := 'Four';
   number_chart (5) := 'Five';
   number_chart (6) := 'Six';
   number_chart (7) := 'Seven';
   number_chart (8) := 'Eight';
   number_chart (9) := 'Nine';
   number_chart (10) := 'Ten';
   number_chart (11) := 'Eleven';
   number_chart (12) := 'Twelve';
   number_chart (13) := 'Thirteen';
   number_chart (14) := 'Fourteen';
   number_chart (15) := 'Fifteen';
   number_chart (16) := 'Sixteen';
   number_chart (17) := 'Seventeen';
   number_chart (18) := 'Eighteen';
   number_chart (19) := 'Nineteen';
   number_chart (20) := 'Twenty';
   number_chart (30) := 'Thirty';
   number_chart (40) := 'Forty';
   number_chart (50) := 'Fifty';
   number_chart (60) := 'Sixty';
   number_chart (70) := 'Seventy';
   number_chart (80) := 'Eighty';
   number_chart (90) := 'Ninety';
   crore := FLOOR (a_number / 10000000);
   lakh := FLOOR ((a_number - TRUNC (a_number, -7)) / 100000);
   thou := FLOOR ((a_number - TRUNC (a_number, -5)) / 1000);
   hund := FLOOR ((a_number - TRUNC (a_number, -3)) / 100);
   doubl := TRUNC (a_number - TRUNC (a_number, -2), 0);
   sing := TRUNC (a_number - TRUNC (a_number, -1), 0);
   deci := (a_number - TRUNC (a_number, 0)) * 100;

   IF crore <> 0
   THEN
      text := spel_out (crore) || ' ' || 'Crore ';
   END IF;

   IF lakh <> 0
   THEN
      IF (lakh <= 20) OR (lakh MOD 10 = 0)
      THEN
         text := text || number_chart (lakh) || ' Lac ';
      ELSE
         text :=
               text
            || number_chart (TRUNC (lakh, -1))
            || '-'
            || number_chart (TRUNC (lakh, 0) - TRUNC (lakh, -1))
            || ' Lakh ';
      END IF;
   END IF;

   IF thou <> 0
   THEN
      IF (thou <= 20) OR (thou MOD 10 = 0)
      THEN
         text := text || number_chart (thou) || ' Thousand ';
      ELSE
         text :=
               text
            || number_chart (TRUNC (thou, -1))
            || '-'
            || number_chart (TRUNC (thou, 0) - TRUNC (thou, -1))
            || ' Thousand ';
      END IF;
   END IF;

   IF hund <> 0
   THEN
      IF (hund <= 20) OR (hund MOD 10 = 0)
      THEN
         text := text || number_chart (hund) || ' Hundred ';
      ELSE
         text :=
               text
            || number_chart (TRUNC (hund, -1))
            || '-'
            || number_chart (TRUNC (hund, 0) - TRUNC (hund, -1))
            || ' Hundred ';
      END IF;
   END IF;

   IF doubl <> 0
   THEN
      IF (doubl <= 20) OR (doubl MOD 10 = 0)
      THEN
         text := text || number_chart (doubl) || ' ';
      ELSE
         text :=
               text
            || number_chart (TRUNC (doubl, -1))
            || ' '
            || number_chart (TRUNC (doubl, 0) - TRUNC (doubl, -1))
            || ' ';
      END IF;
   END IF;

   IF deci <> 0
   THEN
      IF (deci <= 20) OR (deci MOD 10 = 0)
      THEN
         text := text || 'and Paisa ' || number_chart (deci) || '';
      ELSE
         text :=
               text
            || ' and Paisa '
            || number_chart (TRUNC (deci, -1))
            || ' '
            || number_chart (TRUNC (deci, 0) - TRUNC (deci, -1))
            || '';
      END IF;
   END IF;

   RETURN (text);
END spel_out;
/
