USE [master]
GO
/****** Object:  Database [TimeMachineDB]    Script Date: 06/10/2022 0:56:01 ******/
CREATE DATABASE [TimeMachineDB]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'TimeMachine', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\TimeMachine.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'TimeMachine_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\TimeMachine_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
ALTER DATABASE [TimeMachineDB] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [TimeMachineDB].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [TimeMachineDB] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [TimeMachineDB] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [TimeMachineDB] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [TimeMachineDB] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [TimeMachineDB] SET ARITHABORT OFF 
GO
ALTER DATABASE [TimeMachineDB] SET AUTO_CLOSE ON 
GO
ALTER DATABASE [TimeMachineDB] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [TimeMachineDB] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [TimeMachineDB] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [TimeMachineDB] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [TimeMachineDB] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [TimeMachineDB] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [TimeMachineDB] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [TimeMachineDB] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [TimeMachineDB] SET  ENABLE_BROKER 
GO
ALTER DATABASE [TimeMachineDB] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [TimeMachineDB] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [TimeMachineDB] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [TimeMachineDB] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [TimeMachineDB] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [TimeMachineDB] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [TimeMachineDB] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [TimeMachineDB] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [TimeMachineDB] SET  MULTI_USER 
GO
ALTER DATABASE [TimeMachineDB] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [TimeMachineDB] SET DB_CHAINING OFF 
GO
ALTER DATABASE [TimeMachineDB] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [TimeMachineDB] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [TimeMachineDB] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [TimeMachineDB] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
ALTER DATABASE [TimeMachineDB] SET QUERY_STORE = OFF
GO
USE [TimeMachineDB]
GO
/****** Object:  Table [dbo].[Cargo]    Script Date: 06/10/2022 0:56:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Cargo](
	[id_cargo] [int] IDENTITY(1,1) NOT NULL,
	[cargo] [varchar](max) NULL,
	[sueldoPorHora] [numeric](18, 2) NULL,
 CONSTRAINT [PK_Cargo] PRIMARY KEY CLUSTERED 
(
	[id_cargo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Personal]    Script Date: 06/10/2022 0:56:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Personal](
	[id_persona] [int] IDENTITY(1,1) NOT NULL,
	[nombre] [varchar](max) NULL,
	[identificacion] [varchar](max) NULL,
	[pais] [varchar](max) NULL,
	[id_cargo] [int] NULL,
	[sueldoPorHora] [numeric](18, 0) NULL,
	[estado] [varchar](max) NULL,
	[codigo] [varchar](max) NULL,
 CONSTRAINT [PK_Personal] PRIMARY KEY CLUSTERED 
(
	[id_persona] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Personal]  WITH CHECK ADD  CONSTRAINT [FK_Personal_Cargo] FOREIGN KEY([id_cargo])
REFERENCES [dbo].[Cargo] ([id_cargo])
GO
ALTER TABLE [dbo].[Personal] CHECK CONSTRAINT [FK_Personal_Cargo]
GO
/****** Object:  StoredProcedure [dbo].[BuscarPersonal]    Script Date: 06/10/2022 0:56:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[BuscarPersonal]
@desde int, 
@hasta int,
@buscador varchar(50)
AS
SET NOCOUNT ON;
SELECT
id_persona, nombre, identificacion, sueldoPorHora, cargo, id_cargo, estado, codigo
FROM
(SELECT id_persona, nombre, identificacion, Personal.sueldoPorHora, Cargo.cargo, Personal.id_cargo, estado, codigo,
ROW_NUMBER() OVER(ORDER BY id_persona) 'Numero de fila'
FROM Personal
INNER JOIN Cargo ON Cargo.id_cargo = Personal.id_cargo) AS Paginado
WHERE (Paginado.[Numero de fila] >= @desde) AND (Paginado.[Numero de fila] <= @hasta)
AND (nombre + identificacion LIKE '%' + @buscador + '%')
GO
/****** Object:  StoredProcedure [dbo].[EditarPersonal]    Script Date: 06/10/2022 0:56:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[EditarPersonal]
@id_persona int,
@nombre varchar(max),
@identificacion varchar(max),
@pais varchar(max),
@id_cargo varchar(max),
@sueldoPorHora numeric(18,2)
AS
IF EXISTS (SELECT identificacion FROM Personal WHERE identificacion = @identificacion AND id_persona <> @id_persona)
RAISERROR('ya existe un registro con esta identificación', 16, 1)
ELSE
UPDATE Personal SET nombre = @nombre, identificacion = @identificacion, pais = @pais, id_cargo = @id_cargo, sueldoPorHora = @sueldoPorHora
WHERE id_persona = @id_persona
GO
/****** Object:  StoredProcedure [dbo].[EliminarPersonal]    Script Date: 06/10/2022 0:56:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[EliminarPersonal]
@id_persona INT
AS
UPDATE Personal SET estado = 'Eliminado'
WHERE id_persona = @id_persona
GO
/****** Object:  StoredProcedure [dbo].[InsertarPersonal]    Script Date: 06/10/2022 0:56:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[InsertarPersonal]
@Nombre varchar(max),
@identificacion varchar(max),
@pais varchar(max),
@id_cargo int,
@sueldoPorHora numeric(18, 2)
AS
DECLARE @estado varchar(max)
DECLARE @codigo varchar(max)
DECLARE @id_persona int

SET @estado = 'ACTIVO'
SET @codigo = '-'

IF EXISTS (SELECT @identificacion FROM Personal WHERE @identificacion = @identificacion)
RAISERROR('Ya existe un registro con esta identificación',16,1)
ELSE
INSERT INTO Personal VALUES(@Nombre, @identificacion, @pais, @id_cargo, @sueldoPorHora, @estado, @codigo)
SELECT @id_persona = SCOPE_IDENTITY()
UPDATE Personal SET codigo = @id_persona
GO
/****** Object:  StoredProcedure [dbo].[MostrarPersonal]    Script Date: 06/10/2022 0:56:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[MostrarPersonal]
@desde int, 
@hasta int
AS
SET NOCOUNT ON;
SELECT
id_persona, nombre, identificacion, sueldoPorHora, cargo, id_cargo, estado, codigo
FROM
(SELECT id_persona, nombre, identificacion, Personal.sueldoPorHora, Cargo.cargo, Personal.id_cargo, estado, codigo,
ROW_NUMBER() OVER(ORDER BY id_persona) 'Numero de fila'
FROM Personal
INNER JOIN Cargo ON Cargo.id_cargo = Personal.id_cargo) AS Paginado
WHERE (Paginado.[Numero de fila] >= @desde) AND (Paginado.[Numero de fila] <= @hasta)
GO
USE [master]
GO
ALTER DATABASE [TimeMachineDB] SET  READ_WRITE 
GO
