with Ada.Numerics.discrete_Random;
with Ada.Text_IO; use Ada.Text_IO;

procedure Main is

   dim : constant Integer := 100000;
   WorkingThreadCount : constant Integer := 8;
   arr : array(1..dim) of Integer;

   procedure GenerateArray is
      rndIndex : Integer;
      rndValue : Integer;
   begin
      for i in 1..dim loop
         arr(i) := i;
      end loop;

      rndIndex := 25000;
      rndValue := -123456;
      arr(rndIndex) := rndValue;

      Put_Line("Random created index is" & rndIndex'img & ", random created value is " & rndValue'img);
   end GenerateArray;

   task type WorkingThread is
      entry Init(WorkingThread_index : in Integer);
   end WorkingThread;

   protected WorkingThreadManager is
      procedure AddDoneTask(MinIndex : in Integer; MinValue : in Integer; WorkingThreadIndex : in Integer);
      entry GetMinIndexAndValue(MinIndex : out Integer; MinValue : out Integer);
   private
      min_Index : Integer;
      min_Value : Integer;
      flag : Boolean := true;
      tasks_count : Integer;
   end WorkingThreadManager;

   protected body WorkingThreadManager is
      procedure AddDoneTask(MinIndex : in Integer; MinValue : in Integer; WorkingThreadIndex : in Integer) is
      begin
         Put_Line("Min element in WorkingThread" & WorkingThreadIndex'img & " with index" & MinIndex'img & " is " & MinValue'img);

         if (flag) then
            min_Value := MinValue;
            min_Index := MinIndex;
            flag := false;
         else
            if (MinValue < min_Value) then
               min_Value := MinValue;
               min_Index := MinIndex;
            end if;
         end if;
         tasks_count := tasks_count + 1;
      end AddDoneTask;

      entry GetMinIndexAndValue(MinIndex : out Integer; MinValue : out Integer) when tasks_count = WorkingThreadCount is
      begin
         MinIndex := min_Index;
         MinValue := min_Value;
      end GetMinIndexAndValue;
   end WorkingThreadManager;

   task body WorkingThread is
      min_index : Integer;
      min_value : Integer;
      first_index, end_index : Integer;
      WorkingThread_index : Integer;
   begin
      accept Init(WorkingThread_index : in Integer) do
         WorkingThread.WorkingThread_index := WorkingThread_index;
      end Init;

      first_index := ((WorkingThread_index - 1) * dim / WorkingThreadCount) + 1;
      end_index := WorkingThread_index * dim / WorkingThreadCount;
      min_index := first_index;
      min_value := arr(min_index);

      for i in first_index..end_index loop
         if (arr(i) < min_value) then
            min_index := i;
            min_value := arr(i);
         end if;
      end loop;
      WorkingThreadManager.AddDoneTask(min_index, min_value, WorkingThread_index);
   end WorkingThread;

   Workingthreads : array(1..WorkingThreadCount) of WorkingThread;

   procedure PrintResults is
      minIndex : Integer;
      minValue : Integer;
   begin
      WorkingThreadManager.GetMinIndexAndValue(minIndex, minValue);

      Put_Line("Min index is " & minIndex'img & ", min value is " & minValue'img);
   end PrintResults;

begin
   Put_Line("WorkingThreads count is" & WorkingThreadCount'img);

   GenerateArray;
   for i in 1..WorkingThreadCount loop
      Workingthreads(i).Init(i);
   end loop;
   PrintResults;
end Main;
