USE [ERP_HR]
GO
/****** Object:  StoredProcedure [dbo].[sprEmployeeRegistration]    Script Date: 7/13/2025 2:39:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ==========================================
-- Author:		<Md. Golam Kibria Konock>
-- Create date: <15-01-2013> 7	1416	8	2	1	6
-- Modified date: <00-00-2013>
-- Description:	<New Employee Registration>
-- Declare @strMessage varchar(100)
-- Exec sprEmployeeRegistration
--'Test_Wrong1','Wrong','0','01837504227','n/A','Wrong-002',1,'Wrong@akij.net','Presentaddress',6,'M','Permanentaddress', 
--1,53,88,155,1419,8,2,0,1539,1209,'2016-09-22','R666','IBBL','Moulavibazar','0000000000000',1, '','','',
--1056, 23, 1260, 18, '2016-09-01',@strMessage out
-- Select @strMessage
-- =============================================

ALTER PROCEDURE [dbo].[sprEmployeeRegistration]
	@strFullName varchar(1000),
	@strShortName varchar(100),
	@strNationalId varchar(15),
	@strContactNo varchar(20),
	@strBloodGroup varchar(50),
	@strFactoryCode varchar(100),
	@intReligionID int,
	@strOfficeEmail varchar(100),
	@strPresentAddress varchar(500),
	@intDayOffId int,
	@strGender varchar(5),
	@strPermanentAddress varchar(500),
	
	@intGroupId int,
	@intUnitId int,
	@intJobStationID int,
	@intJobTypeId int,
	@intDesignationID int,
	@intDepartmentID int,
	@intDutyCatagory int,
	@strContactPeriod varchar(100),
	@intTeamID int,
	@intPresentShiftID int,
	@dteJoiningDate datetime,
	--@dteAppointmentDate datetime,
	@strSuperviserCode varchar(100),
	@strFloorAccess varchar (75),
		
	@strBankName varchar(100),
	@strBranchName varchar(100),
	@strAccountNo varchar(100),	
	@monSalary money,
	--@monBasicAmount money,
	--@pfPercentance decimal(18,2),
	--@strPaymentType varchar(100),	
	@strPhotoUrl varchar(100),	
	@strDocumentUrl varchar(100),	
	@strDocumentType varchar(100),	
	@intLoginUserID int, 
	@bank int, @branch int, @dist int, @dteBirth datetime,
	@strByteStringPic varbinary(max),@strbytetypePic varchar(50),@strByteStringDoc varbinary(max),@strbyteTypeDoc varchar(50),
	@strMessage varchar(200) out
AS
BEGIN

	Begin Try	
		------------CHECK EMPLOYEE EXITS OR NOT----------------
		
		If exists(Select 1 From tblEmployee Where strNationalId=@strNationalId And strEmployeeName=@strFullName
		And intUnitID=@intUnitId And intJobStationID=@intJobStationID)	
		Begin	
			Set @strMessage = 'Employee allready exists for this unit.'
		End		
		--else If exists(Select 1 From tblEmployee Where strBankAccountNo= @strAccountNo and ysnActive=1)	
		--Begin	
		--	Set @strMessage = 'Sorrry to registered. Employee Bank Account already exists.'
		--End
		------------IF EMPLOYEE NOT EXITS THEN INSERTION-------
		Else	
		Begin
			Declare @empId varchar(100), @strJobTypeShort varchar(100),	@strPaymentType varchar(100), @monBasicAmount money,
			@pfPercentance decimal(18,2), @strPunchCard varchar(100)			
			Select @strJobTypeShort=strJobTypeShort From tblUserJobType Where intJobTypeID = @intJobTypeId and
			intUnitID = @intUnitId
			If(@strJobTypeShort='Casual')
			Begin	
				Set @intDayOffId=0
				Set @strPaymentType='H'
				if(@monSalary>500)
				begin
					set @monSalary=0
				end
			End
			Else If(@strJobTypeShort='Piece')
			Begin	
				Set @intDayOffId=0
				Set @strPaymentType='P'
				if(@monSalary>500)
				begin
					set @monSalary=0
				end
			End
			Else
			Begin
				Set @strPaymentType='D'				
			End
			/*----- Change By Konock @ 6th July'2013 -------------*/	
			Declare @dteAppointmentDate date, @ysnManual bit, @ysnPFManual bit--, @monBasicAmount money
			Set @dteAppointmentDate = Getdate()
			If(@strJobTypeShort = 'Contactual' OR @strJobTypeShort = 'Probationary' OR @strJobTypeShort = 'Regular' OR @strJobTypeShort = 'Casual' OR @strJobTypeShort = 'Piece')
			Begin	
				Set @monBasicAmount=0
			End
			else
			Begin
				Set @monBasicAmount = (50 * @monSalary)/100
			end
			--IF(@strFloorAccess IS NULL)
			--BEGIN
			--	SET @strFloorAccess = '0'
			--END

			/*----- End Change Here (Edited fields Joindate, and basic Lock from UI) -------------*/	
				
			Insert into dbo.tblEmployee (intAppTypeId, strEmployeeName, strSortName, strNationalId, strContactNo1, strBloodGroup,
			strEmployeeCode, intReligionID, strOfficeEmail, strPresentAddress, intDayOffId, strGender, strPermanentAddress,
			intGroupID, intUnitID, intJobStationID, intJobTypeId, intDesignationID, intDepartmentID, intDutyCatagoryID, strContactPeriod, 
			intPresentShiftID,dteJoiningDate,dteAppointmentDate, intSuperviserId, strBankName, strBranchName, strBankAccountNo, monSalary, 
			monBasic, strPaymentType, intSoftwareLoginUserID, ysnNewCardInstallation, ysnSalaryHold, strSalaryUnit, ysnActive, strEmpImageUrl,
			strDocumentLink1, strDocumentType, intBankId, intDistrictId, intBranchId, dteBirth,intPersonalUseFuelRateType, strFloorAccess,strByteStringPic,strByteTypePic,strByteString,strByteType)
			Values ( 1, @strFullName, @strShortName, @strNationalId, @strContactNo, @strBloodGroup, @strFactoryCode, 
			@intReligionID, @strOfficeEmail, @strPresentAddress, @intDayOffId, @strGender, @strPermanentAddress,			
			@intGroupId, @intUnitId, @intJobStationID,@intJobTypeId, @intDesignationID, @intDepartmentID, @intDutyCatagory,
			@strContactPeriod, @intPresentShiftID, cast(@dteJoiningDate as date), @dteAppointmentDate, (select intEmployeeID from tblEmployee where strEmployeeCode=@strSuperviserCode),
			@strBankName, @strBranchName, @strAccountNo, @monSalary, @monBasicAmount, @strPaymentType, @intLoginUserID, 1, 0, 
			@intUnitId, 1, @strPhotoUrl, @strDocumentUrl, @strDocumentType, @bank, @dist, @branch, cast(@dteBirth as date),1, @strFloorAccess,@strByteStringPic,@strbytetypePic,@strByteStringDoc,@strbyteTypeDoc)
			
			---Get Employees auto increment number i.d identity and Generate EmployeeCode and Punchcard
			--Declare @empId varchar(100), @strJobTypeShort varchar(100),	@strPunchCard varchar(100)			
			Set @empId = SCOPE_IDENTITY()			
			--Select @strJobTypeShort=strJobTypeShort From tblUserJobType Where intJobTypeID = @intJobTypeId and
			--intUnitID = @intUnitId
			Set @strPunchCard= @strJobTypeShort+'-'+@empId
			Update tblEmployee Set strEmployeePunchCardCode = @strPunchCard	
			Where intEmployeeID=@empId and intUnitID=@intUnitId and intJobStationID=@intJobStationID
			Update ERP_HR.dbo.tblEmployee Set strEmployeeCode=@empId Where intEmployeeID=@empId and intUnitID=13 and 
			intJobStationID=@intJobStationID and intDesignationID in (1448,1503,1504)

			--if(@intDesignationID in (1461,1487,1482,1376,1452,1454,1446,1453,1431,1460,1455, 1447,1462,1392,1410,1377,
			--1401,1448,1450,1458,1457, 1503, 1504, 1505, 1506,1507, 1510, 1511) and @intunitid=13)
			--Begin	
			--	Declare @coa int
			--	--Select @coa = MAX(intCOAID)+1 from ERP_ACLPoint.dbo.tblPointChartOfAccount
			--	Select top(1) @coa = intCOAID + 1 from ERP_ACLPoint.dbo.tblPointChartOfAccount Order by intCOAID desc
			--	Insert into ERP_ACLPoint.dbo.tblPointChartOfAccount (intCOAID, intPointID, intModule, strAccName, intParentID, strCode, 
			--	intChildCount, monCurrentBalance, monOpeningBalance, ysnEnable, ysnPointAllowable)
			--	Select @coa, intJobStationID, intEmployeeID, strEmployeeName, (select intCOAID from ERP_ACLPoint.dbo.tblPointChartOfAccount 
			--	where strAccName='Staff Deposit' and intPointID=@intJobStationID), '', 0, 0.00, 0.00, 1, 1 
			--	From erp_hr.dbo.tblEmployee where intJobStationID=@intJobStationID and ysnactive=1 and intEmployeeID=@empId

			--	Update ERP_ACLPoint.dbo.tblPointChartOfAccount set strCode=cast(@coa as varchar(250)) + 
			--	cast(@intJobStationID as varchar(250)) + (select cast(intCOAID as varchar(100)) from ERP_ACLPoint.dbo.tblPointChartOfAccount 
			--	where strAccName='Staff Deposit' and intPointID=@intJobStationID) where intCOAID=@coa
			
			--	Update ERP_ACLPoint.dbo.tblPointChartOfAccount set intChildCount=intChildCount + 1
			--	where strAccName='Staff Deposit' and intPointID=@intJobStationID
			--End
			

		
			------------Employee Salary Information Insertion------@pfPercentance=numPFPercentance,----------
			Declare @basicPercentance  decimal(18,2), @hRentPercentance  decimal(18,2), @hRentAmount money, 
			@mAllowncePercentance  decimal(18,2), @mAllownceAmount money,	@transportPercentance  decimal(18,2), 
			@transportAmount money, @otherAmount money, @pfAmount money, 
			@taxPercentance  decimal(18,2),  @monTaxAbleAmount money, @taxAmount money

			Select @basicPercentance = isnull(numBasicPercentance,0), @hRentPercentance=isnull(numHouseRentPercentance,0), 
			@mAllowncePercentance=isnull(numMedicalAllowancePercentance,0), @transportPercentance=isnull(numTransportPercentance,0), 
			@pfPercentance= isnull(numPFPercentance,0), @taxPercentance=isnull(numTaxPercentance,0) From tblEmployeeGroupPermissionSalary 
			Where intGroupID=@intGroupId AND intJobTypeId=@intJobTypeId AND intJobStationID=@intJobStationID
			
			Set @hRentAmount = (@hRentPercentance*@monBasicAmount)/100
			Set @mAllownceAmount = (@mAllowncePercentance*@monBasicAmount)/100
			Set @transportAmount = (@transportPercentance*@monBasicAmount)/100
			Set @otherAmount = case when @monBasicAmount=0 then 0 else  (@monSalary-(@monBasicAmount + @hRentAmount + @mAllownceAmount + @transportAmount)) end
			If(@strJobTypeShort = 'Contactual' OR @strJobTypeShort = 'Probationary' OR @strJobTypeShort = 'Regular' OR @strJobTypeShort = 'Casual' OR @strJobTypeShort = 'Piece')
			Begin	
				Set @monBasicAmount=0
				Set @pfPercentance=0
				Set @pfAmount = 0
			End
			else
			Begin 
				Set @pfAmount = (@pfPercentance*@monBasicAmount)/100
			End
			Select @monTaxAbleAmount=monTaxableAmount from dbo.funTaxableAmountCalculate(@empId)		
			Set @taxAmount=(@taxPercentance*@monTaxAbleAmount)/100
			
			Insert into dbo.tblEmployeeSalary ( intEmployeeID, monTotalSalary,numBasicPercentance,monBasicAmount,numHouseRentPercentance,
			monHouseRentAmount,numMedicalAllowancePercentance,monMedicalAllowanceAmount,numTransportPercentance,
			monTransportAmount, monOtherAmount, numPFPercentance,monPFAmount,numTaxPercentance,monTaxableAmount,monTaxAmount)		
			Values ( @empId, Round(@monSalary,0), @basicPercentance, Round(@monBasicAmount,0), @hRentPercentance, Round(@hRentAmount,0), 
			@mAllowncePercentance, Round(@mAllownceAmount,0), @transportPercentance, Round(@transportAmount,0), Round(@otherAmount,0), @pfPercentance, 
			Round(@pfAmount,0), @taxPercentance, @monTaxAbleAmount, @taxAmount )
		
			------------Employee Leave Information Insertion----------------
			if(@strJobTypeShort = 'Probationary')
			Begin	
				Insert into erp_hr.dbo.tblLeaveBalance ( intLeaveTypeId, intEmployeeID, intLeaveTakenDays, intRemainingDays, strRemarks,intBalanceDays) 
				Values ( 2, @empId, 0, 3, 'Casual Leave', 3)
				Insert into erp_hr.dbo.tblLeaveBalance ( intLeaveTypeId, intEmployeeID, intLeaveTakenDays, intRemainingDays, strRemarks,intBalanceDays) 
				Values ( 4, @empId, 0, 7, 'Medical Leave', 0)
			End
			else 
			Begin	
				Declare @intLeaveTypeId int, @intAllowedLeaveDays int, @intRow int
				Declare @tblLeave Table	
				(intRowId int IDENTITY(1,1) NOT NULL, intLeaveTypeID int, intNumberOfLeave int, ysnParse bit )
				Insert into @tblLeave (intLeaveTypeID, intNumberOfLeave, ysnParse)	
				Select intLeaveTypeID, intNumberOfLeave, 0 From tblEmployeeGroupPermissionLeave 
				Where intGroupID=@intGroupId AND intJobTypeId=@intJobTypeId AND intJobStationID=@intJobStationID
				While ((Select COUNT(*) from @tblLeave where ysnParse=0)>0)	
				Begin	
					Select Top(1) @intRow=intRowId, @intLeaveTypeId=intLeaveTypeID, @intAllowedLeaveDays=intNumberOfLeave 
					From @tblLeave Where ysnParse=0 
					Insert into dbo.tblLeaveBalance ( intLeaveTypeId, intEmployeeID, intLeaveTakenDays, intRemainingDays, strRemarks,
					intBalanceDays) Values ( @intLeaveTypeId, @empId, 0, 
					Case When (@intLeaveTypeId=2 and (@strJobTypeShort='Permanent' Or @strJobTypeShort='Contactual')) Then 1 Else @intAllowedLeaveDays End, 
					'N/A', Case When (@intLeaveTypeId=2 and (@strJobTypeShort='Permanent' Or @strJobTypeShort='Contactual')) Then 1 Else 0 End)
					-------------- Insert for All ATML Unit ----------------
					if exists(select 1 from erp_hr.dbo.QryEmployeeProfileAll where ysnActive=1 and intJobStationID in (26, 27, 461, 1248) 
					and intJobTypeId in (56,66,72,74,131,132,134,136) and intEmployeeID=@empId and @intLeaveTypeId in (2,4))
					Begin	
						Insert into dbo.tblLeaveBalance ( intLeaveTypeId, intEmployeeID, intLeaveTakenDays, intRemainingDays, strRemarks,
						intBalanceDays) Values ( @intLeaveTypeId, @empId, 0, Case When @intLeaveTypeId=2 Then 1 Else @intAllowedLeaveDays End, 
						'N/A', Case When @intLeaveTypeId=2 Then 1 Else 0 End)
					End
					-------------- Insert for All AJML Unit ----------------
					if exists(select 1 from erp_hr.dbo.QryEmployeeProfileAll where ysnActive=1 and intJobStationID in (41,96,97,426,433,439,479,480,481,482,423,430,432,443,459,462) 
					and intJobTypeId in (43) and intEmployeeID=@empId and @intLeaveTypeId in (7))
					Begin	
						Insert into dbo.tblLeaveBalance ( intLeaveTypeId, intEmployeeID, intLeaveTakenDays, intRemainingDays, strRemarks,
						intBalanceDays) Values ( @intLeaveTypeId, @empId, 0, 5, 'N/A', Case When @intLeaveTypeId=2 Then 1 Else 0 End)
					End
					Update @tblLeave Set ysnParse=1 where intRowId=@intRow	
				End
			End			
			------------Employee Roster(Shift) Information Insertion---------			
			If exists (Select 1 From tblEmployeeTeamShift where intShiftId=@intPresentShiftID and intSequenceId<>0 and ysnRoster=1)
			Begin	
				Declare @intSequenceId int, @intInsertRows int, @dteNextChangeRoster date
				Select @intSequenceId=shift.intSequenceId From dbo.tblEmployeeTeamBuild team 
				INNER JOIN dbo.tblEmployeeTeamShift shift ON team.intTeamId = shift.intTeamId 
				Where team.intUnitId=@intUnitId and team.intJobStationID=@intJobStationID and 
				team.intTeamId=@intTeamId and shift.intShiftId=@intPresentShiftID				
				Select @dteNextChangeRoster = dteNextChangeDate From dbo.tblEmployeeTeamShiftRosterScheduleConfig
				Where intUnitId = @intUnitId and intJobStationId = @intJobStationID and intTeamId=@intTeamID				
				Set @intInsertRows=DATEDIFF(DD,@dteJoiningDate,@dteNextChangeRoster)
							
				While(@intInsertRows>0) 
				Begin 
					Insert into dbo.tblEmployeeTeamShiftRoster (intJobStationId,dteRosterDutyDate,intEmployeeId,
					intPresentShiftId,intShiftSequenceNo,ysnRegular,ysnOverTime,ysnConsecutive) Values 
					(@intJobStationID,@dteJoiningDate,@empId,@intPresentShiftID,@intSequenceId,1,0,0)
					Set @dteJoiningDate = DATEADD(D,1,@dteJoiningDate)
					Set @intInsertRows = @intInsertRows - 1					
				End
			End
			
			Insert into dbo.tblLetterIssue( intEmployeeID, intLetterId, dteIssueDate ) VALUES ( @empId, 3, @dteAppointmentDate)
			
			------------Employee Information Insertion For Log----------------
			Insert into dbo.tblHRDataHistory (strAction,strDescription,strTblName,dteDate,intUserID) 
			Values ('Insert', 'New Employee Registration( '+Cast(@empId as varchar(100)) +' )','tblEmployee',GETDATE(),@intLoginUserID)
			If(@monBasicAmount = (50 * @monSalary)/100)
			Begin	
				Set @ysnManual=0
			End
			Else
			Begin	
				Set @ysnManual=1
			End
			If(@pfAmount = (10 * @monBasicAmount)/100)
			Begin	
				Set @ysnPFManual=0
			End
			Else
			Begin	
				Set @ysnPFManual=1
			End

			------------ Use for User login ------------------
			if((@strOfficeEmail is not NULL) or (@strOfficeEmail != ''))
			Begin	
				if exists (select 1 from erp_hr.dbo.tblUserInfo where strUserCode=@strOfficeEmail Or strEmail=@strOfficeEmail)
				begin	
					Update dbo.tblEmployee Set strOfficeEmail=@strOfficeEmail where intEmployeeID=@empId
					--delete from erp_HR.dbo.tblUserInfo where strUserCode=@strEmail Or strEmail=@strEmail
				end
				else 
				Begin	
					Insert into ERP_HR.dbo.tblUserInfo (intUserID, strUserCode, strName, strSortName, strEmail, strPhone1, dteAppointmentDate, intJobTypeID, intUnitID, 
					intDepartmentID, intDesignationID, ysnActive, intParentUserID, intLevel, intEmployeeID)
					Select intEmployeeID, strOfficeEmail, strEmployeeName, isnull(strSortName, strEmployeeName), strOfficeEmail, strContactNo1, dteJoiningDate, intJobTypeId, intUnitID,
					intDepartmentID, intDesignationID, 1, 1, 0, intEmployeeID from ERP_HR.dbo.tblEmployee where intEmployeeID in (@empId)
				End
			End

			--if(@intDesignationId in (1431, 1453, 1482, 1461, 1487) and @intUnitId=13 and @strOfficeEmail != '')
			--Begin	
			--	Update erp_hr.dbo.tblEmployee set intSuperviserId=@empId where intDesignationID not in 
			--	(1369, 1464, 1456, 1408, 1425, 1374, 1483) and intJobStationID=@intJobStationID and ysnActive=1
			--	Set @monthfirst = cast(DATEADD(mm, DATEDIFF(mm, 0, GETDATE()), 0) as date)
			--	if(@dtejoin <= @monthfirst)
			--	Begin	
			--		Update erp_hr.dbo.tblEmployeeAttendance set intJobStationID=@intStationId where intEmployeeID=@intEmployeeId 
			--		and (dteAttendanceDate between @monthfirst and Cast(Getdate() as date))
			--	End
			--	else
			--	Begin	
			--		Update erp_hr.dbo.tblEmployeeAttendance set intJobStationID=@intStationId where intEmployeeID=@intEmployeeId 
			--		and (dteAttendanceDate between @dtejoin and Cast(Getdate() as date))
			--	End
			--End
			----------------------------------------------------
			Insert into Archive_HR.dbo.tblLogEmployee (strAction, strActionIn, dteActionDate, intActionBy, intEmployeeID, strEmployeeName, 
			intGroupID, intUnitID, intJobStationID, intJobTypeId,intDesignationID, intDepartmentID, intPresentShiftID, intDayOffId, 
			strPunchCardCode, strContactPeriod, dteJoiningDate, strBankName, strBranchName, strBankAccountNo, monSalary, monBasic, 
			ysnActive, ysnSalaryHold, strContactNo, strPaymentType, ysnBasicManual, ysnPFManual)
			Values ('Registration', 'New Employee',Getdate(),@intLoginUserID,@empId,@strFullName,@intGroupId,@intUnitId,
			@intJobStationID,@intJobTypeId,@intDesignationID,@intDepartmentID,@intPresentShiftID,@intDayOffId,@strPunchCard,@strContactPeriod,
			@dteJoiningDate,@strBankName,@strBranchName,@strAccountNo,@monSalary,@monBasicAmount,1,0,@strContactNo,@strPaymentType,@ysnManual,@ysnPFManual)
			

          ------------------------------------- For TA DA Supervisor Set (Add by Monir) ------------------------
		  declare @countinemp int
		  set @countinemp=(select   isnull(count(intSupervisorId),0) from BrandTradeMkt.dbo.tblTADAPermissionGlobal where intEmployeeid=@empId  )
		  if(	@countinemp=0)
				begin
					if not exists( select distinct 1 from BrandTradeMkt.dbo.tblTADAPermissionGlobal where intEmployeeid=@empId  )
					begin
					insert into BrandTradeMkt.dbo.tblTADAPermissionGlobal ( intEmployeeid,intSupervisorId,intLevel,intUnit,intInsertBy,dteInsertiondate,intJobstation,intDeptid,ysnActive)
					values (@empId, (select intEmployeeID from tblEmployee where strEmployeeCode=@strSuperviserCode),3,@intUnitId,@intLoginUserID,getdate(),@intJobStationID,@intDepartmentID,1)
				end	

				  ------------------------------------- For Apps User Default Permission (Add by Monir) ------------------------
				  if (@intUnitId=4 or @intUnitId=8 or @intUnitId=17)
				  begin
					if not exists (select 1 from ERP_APPS.dbo.tblAppsUserIDNPasswd where intEnrol=@empId)
						begin

							insert into ERP_APPS.dbo.tblAppsUserIDNPasswd(intUnitId,strName,intEnrol,ysnEnable,intInsertby,dteInsertDate,strPhone,strPasswd,strUserName,ysnOwnUser,intCustomerID,intUserTypeID )
							select intUnitID,strEmployeeName,@empId,1,@intLoginUserID,getdate(),strContactNo1,@empId,@empId,1,0,10 from erp_hr.dbo.tblemployee where intEmployeeID=476746  
						end

                  end

		 end
		--Declare @row int,@moduleRole int
		--Declare @tblPermissionTADA table(RowId int identity(1,1),intRoleid int,ysnFavorite bit,ysnActive bit,ysnProceed bit)
		--insert into @tblPermissionTADA(intRoleid ,ysnFavorite ,ysnActive ,ysnProceed )
		-- SELECT  intRoleID,0,1,0 FROM BrandTradeMkt.dbo.tblTADAModulePermissionGlobal

		--  while((select count(*)from @tblPermissionTADA where ysnProceed=0)>0)
		--  Select top(1) @row=RowId,@moduleRole=intRoleid  from @tblPermissionTADA where ysnProceed = 0
		--insert into DB_Role.dbo.tblRolePermissionByEnroll (intEnroll,intRoleID,ysnFavorite,ysnActive,intPermissionEnroll,dteInsertTime)
		--values (@empId,@moduleRole,0,1,@intLoginUserID,getdate())
		--  Update @tblPermissionTADA set ysnProceed=1 where RowId=@row
			
			------------------------ Leave Balance Update/Insert for Probetionery Employee ------------------------------------------------

			--SELECT @strJobTypeShort = strJobTypeShort FROM ERP_HR.dbo.QRYEMPLOYEEPROFILEALL WHERE intEmployeeID = @empId
			--IF (@strJobTypeShort = 'Probationary')
			--BEGIN -- Casula Leave Update or Insert
			--	IF EXISTS (SELECT * FROM ERP_HR.dbo.tblLeaveBalance WHERE intLeaveTypeId = 2 AND intEmployeeID = @empId)
			--	BEGIN
			--		UPDATE ERP_HR.dbo.tblLeaveBalance SET intBalanceDays = 3, intRemainingDays = 3 WHERE intLeaveTypeId = 2 AND intEmployeeID = @empId
			--	END
			--	ELSE
			--	BEGIN
			--		INSERT INTO ERP_HR.dbo.tblLeaveBalance (intLeaveTypeId, intEmployeeID, intLeaveTakenDays, intRemainingDays, strRemarks, intBalanceDays)
			--		VALUES (2, @empId, 0, 3, 'Casual Leave', 3)
			--	END
			--	-- Medical Leave Update Insert
			--	IF EXISTS (SELECT * FROM ERP_HR.dbo.tblLeaveBalance WHERE intLeaveTypeId = 4 AND intEmployeeID = @empId)
			--	BEGIN
			--		UPDATE ERP_HR.dbo.tblLeaveBalance SET intRemainingDays = 7 WHERE intLeaveTypeId = 4 AND intEmployeeID = @empId
			--	END
			--	ELSE
			--	BEGIN
			--		INSERT INTO ERP_HR.dbo.tblLeaveBalance (intLeaveTypeId, intEmployeeID, intLeaveTakenDays, intRemainingDays, strRemarks, intBalanceDays)
			--		VALUES (4, @empId, 0, 7, 'Medical Leave', 0)
			--	END
			--END
			--------------------------------------------------------------------------------------------------------------------------------

			--==== Below Code By alamin@akij.net ========================================================================
			---EXEC ERP_Accounts.dbo.sprGLCodeBridge @empId, 0, 0, 1, @intUnitId, 'N/A', @intLoginUserID
			--===========================================================================================================

			Set @strMessage='Employee registration has been completed successfully. Your Enroll No. is  ' + @empId
		End
		
	End Try

	Begin Catch	
		Set @strMessage = 'Sorry! There was an error! ' + ERROR_MESSAGE()
	End Catch
		
END

SET ANSI_NULLS ON
