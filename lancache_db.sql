

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `lancache_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `access_logs`
--

CREATE TABLE `access_logs` (
  `LID` int NOT NULL AUTO_INCREMENT,
  `LogDate` datetime NOT NULL DEFAULT current_timestamp(),
  `Upstream` varchar(100) NOT NULL,
  `LStatus` varchar(20) NOT NULL,
  `IP` varchar(15) DEFAULT NULL,
  `Bytes` bigint UNSIGNED DEFAULT NULL,
  `App` varchar(300) DEFAULT NULL,
  PRIMARY KEY (`LID`),
  KEY `TRACE` (`LogDate`,`LStatus`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `cache_disk`
--

CREATE TABLE `cache_disk` (
  `Location` varchar(4) NOT NULL,
  `KiBUsed` bigint NOT NULL,
  `KiBFree` bigint NOT NULL,
  PRIMARY KEY (`Location`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `cache_disk`
--

INSERT INTO `cache_disk` (`Location`, `KiBUsed`, `KiBFree`) VALUES
('data', 0, 0),
('logs', 0, 0);

-- --------------------------------------------------------

--
-- Table structure for table `steamapps`
--

CREATE TABLE `steamapps` (
  `AppID` int NOT NULL,
  `AppName` varchar(500) NOT NULL
  PRIMARY KEY (`AppID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `steamapps`
--

INSERT INTO `steamapps` (`AppID`, `AppName`) VALUES
(735, 'Counter-Strike 2'),
(578082, 'PUBG: BATTLEGROUNDS'),
(945361, 'Among Us'),
(1899671, 'Grand Theft Auto V'),
(2347770, 'Counter-Strike 2'),
(2347771, 'Counter-Strike 2');

--
-- AUTO_INCREMENT for dumped tables
--

COMMIT;
