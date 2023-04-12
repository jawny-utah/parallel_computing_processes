with Ada.Text_Io, Ada.Integer_Text_IO;
use Ada.Text_IO, Ada.Integer_Text_IO;

procedure Main is
   can_stop : boolean := false;
   pragma Volatile(can_stop);
   threads_count : Integer := 16;
   tmpVar : Integer := 0;

   task break_thread;
   task type main_thread is
      entry Start;
      entry Finish(Sum : Out Integer; Elements : out Integer);
   end main_thread;

   task body break_thread is
   begin
      delay 5.0;
      can_stop  := true;
   end break_thread;

   task body main_thread is
      Sum : Integer := 0;
      Elements : Integer := 0;
   begin
      accept Start;

      loop
         Sum := Sum + threads_count;
         Elements := Elements + 1;
         tmpVar := tmpVar + 1;
         exit when can_stop;
      end loop;
      accept Finish (Sum : out Integer; Elements : out Integer) do
         Sum := main_thread.Sum;
         Elements := main_thread.Elements;
      end Finish;
   end main_thread;

   A : Array(1..threads_count) of main_thread;
   S : Array(1..threads_count) of Integer;
   E : Array(1..threads_count) of Integer;

begin
   for i in A'Range loop
      A(i).Start;
   end loop;

   for i in A'Range loop
      A(i).Finish(S(i), E(i));
   end loop;

   for i in S'Range loop
      Put_Line("Result sum in Thread" & i'Img & " is" & S(i)'Img & ", Elements count is" & E(i)'Img);
   end loop;
end Main;
