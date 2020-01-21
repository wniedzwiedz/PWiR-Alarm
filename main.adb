with Ada.Text_IO, Ada.Integer_Text_IO;
use Ada.Text_IO, Ada.Integer_Text_IO;


procedure Main is

   pass : Integer := 1111;

   sensorNum : Integer := 4;
   i : Integer := sensorNum+1;
   alarming: Boolean := false;
   wait: Boolean := false;
   police : Boolean := false;
   active : Boolean := true;



   task type Sensor(Id_in : Integer) is
      entry Init(Id_in : Integer);
      entry Start;
      entry Stop;
      entry Check;
      entry Al;
   end Sensor;


   task type AlarmMain is
      entry Alarming;
      entry CheckSensors;
      entry ChangePass;
      entry TurnOff;
      entry CallPolice;
   end AlarmMain;

   task GetInput is
   end GetInput;



   Sensors : array (1 .. sensorNum) of Sensor(0);
   Alarm : AlarmMain;



   task body AlarmMain is
   begin

      Put_Line("Alarm ready");

      loop

         Put(ASCII.ESC & "[2J");
         if active then
         Put_Line("Alarm is active");
         Put_Line("Enter the current password to change it");
         Put_Line("Enter 0 to turn off");
         end if;

         select


            accept Alarming do
               Put(ASCII.ESC & "[2J");
               Put_Line("Alarm!! Enter the password ");
               delay 5.0;
               if i = pass then
                  Put_Line("Password accepted");
                  wait:=false;
                  i:=sensorNum+1;
                  delay 3.0;
               else
                  Put_Line("ALARM!!");
                  wait:=false;
                  police:=true;
               end if;

            end Alarming;


         or


            accept CheckSensors do

               for i in Sensors'Range loop
                  Sensors(i).Check;
                  delay 2.0;
               end loop;

            end CheckSensors;


         or


            accept ChangePass  do

               Put(ASCII.ESC & "[2J");
               i:=sensorNum+1;
               Put_Line("Enter current password");
               delay 5.0;

               if i=pass then
                  Put_Line("Enter new password");
                  delay 5.0;

                  if i>999 and i<10000 then
                     pass:=i;
                     Put_Line("Password set as "& pass'Img);

                  else
                     Put_Line("Password must be 4 numbers long. Change cancelled.");
                  end if;

                  i:=sensorNum+1;

                  delay 3.0;

               end if;

            end ChangePass;


         or


            accept TurnOff  do

               Put(ASCII.ESC & "[2J");
               Put_Line("Enter current password to shut down");
               delay 5.0;

               if i=pass then
                  Put_Line("Alarm will shut down now...");
                  i:=sensorNum+1;
                  active := false;
                  delay 3.0;
               end if;

            end TurnOff;

         or

            accept CallPolice  do
               Put(ASCII.ESC & "[2J");
               while i/=pass loop
                  Put("ALARM!! POLICE!! ");
                  delay 0.1;
               end loop;
               police:=false;
               i:=sensorNum+1;
               Put_Line("Alarm stopped");
               delay 3.0;
            end CallPolice;


         end select;


      end loop;


   end AlarmMain;



   task body Sensor is
      sensorID: Integer := Id_in;
      isOn: Boolean := false;

   begin

      loop

         select


            accept Init(Id_in : Integer) do
               sensorID := Id_in;
            end Init;
            accept Start do

               if(sensorID>0) then
                  isOn := true;
                  Put_Line("Sensor id " & sensorID'Img & " ON");
               end if;
            end Start;

         or


            accept Stop do
               isOn := false;
               Put_Line("Sensor id " & sensorID'Img & " OFF");
            end Stop;

         or

            accept Check do
               if not wait then
                  Put_Line("Checking sensor "& sensorID'Img);
                  if alarming and sensorID=i then
                     alarming := false;
                     wait := true;
                     Put_Line("ALARM! Sensor: " & sensorID'Img);
                  end if;
               end if;
            end Check;


         or


            accept Al do
               alarming := true;
            end Al;


         or


            delay 3.0;

         end select;



      end loop;


   exception
      when others => Put_Line("EXCEPTION: sensor " & sensorID'Img);


   end Sensor;



   task body GetInput is
   begin

      loop

         if not alarming then
            Get(i);

            if i in Sensors'Range then
               Sensors(i).Al;
            end if;

            delay 1.0;
         end if;

      end loop;

   end GetInput;




begin
   Put_Line("START");

   for i in Sensors'Range loop

      Sensors(i).Init(i);
      Sensors(i).Start;

   end loop;

   delay 3.0;
   Put(ASCII.ESC & "[2J");


   while active loop




      if wait and not police then
         Alarm.Alarming;
      elsif police then
         Alarm.CallPolice;

         elsif not wait and not police then
            if i=pass then
               Alarm.ChangePass;
            elsif i=0 then
               Alarm.TurnOff;

            else
               Alarm.CheckSensors;
            end if;

      end if;

      active:=active;


      end loop;
      Put(ASCII.ESC & "[2J");
      Put_Line("SHUTTING DOWN...");

   end Main;
