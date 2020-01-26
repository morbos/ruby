#! /usr/bin/ruby
require 'optparse'
require 'scanf'

ARGV << '-h' if ARGV.empty?

$work = Array.new
IO.readlines(ARGV[0]).each do |line|
#  p line
  a = line.scanf "0x%08x:\t0x%02x\t0x%02x\t0x%02x\t0x%02x\t0x%02x\t0x%02x\t0x%02x\t0x%02x\n"
#  p a
  for i in 1 .. a.size-1 do
    $work.push(a[i])
  end
  break if a.size < 9
end

$work.each_with_index { |x,i| printf "%02x %05d\n", x, i }

$pkt = []

$idx = 0

$tuple = Hash.new
$tuple = {[0x4,0x0001] => ["OCF_READ_LOCAL_VERSION", :OCF_GENERIC, :READ_LOCAL_VERSION_RP],
          [0x8,0x0001] => ["OCF_LE_SET_EVENT_MASK", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x8,0x0002] => ["OCF_LE_READ_BUFFER_SIZE", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x8,0x0003] => ["OCF_LE_READ_LOCAL_SUPPORTED_FEATURES", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x8,0x0005] => ["OCF_LE_SET_RANDOM_ADDRESS", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x8,0x0006] => ["OCF_LE_SET_ADV_PARAMETERS", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x8,0x0007] => ["OCF_LE_READ_ADV_CHANNEL_TX_POWER", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x8,0x0008] => ["OCF_LE_SET_ADV_DATA", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x8,0x0009] => ["OCF_LE_SET_SCAN_RESPONSE_DATA", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x8,0x000A] => ["OCF_LE_SET_ADVERTISE_ENABLE", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x8,0x000B] => ["OCF_LE_SET_SCAN_PARAMETERS", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x8,0x000C] => ["OCF_LE_SET_SCAN_ENABLE", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x8,0x000D] => ["OCF_LE_CREATE_CONN", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x8,0x000E] => ["OCF_LE_CREATE_CONN_CANCEL", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x8,0x000F] => ["OCF_LE_READ_WHITE_LIST_SIZE", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x8,0x0010] => ["OCF_LE_CLEAR_WHITE_LIST", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x8,0x0011] => ["OCF_LE_ADD_DEVICE_TO_WHITE_LIST", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x8,0x0012] => ["OCF_LE_REMOVE_DEVICE_FROM_WHITE_LIST", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x8,0x0013] => ["OCF_LE_CONN_UPDATE", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x8,0x0014] => ["OCF_LE_SET_HOST_CHANNEL_CLASSIFICATION", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x8,0x0015] => ["OCF_LE_READ_CHANNEL_MAP", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x8,0x0016] => ["OCF_LE_READ_REMOTE_USED_FEATURES", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x8,0x0017] => ["OCF_LE_ENCRYPT", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x8,0x0018] => ["OCF_LE_RAND", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x8,0x0019] => ["OCF_LE_START_ENCRYPTION", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x8,0x001A] => ["OCF_LE_LTK_REPLY", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x8,0x001B] => ["OCF_LE_LTK_NEG_REPLY", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x8,0x001C] => ["OCF_LE_READ_SUPPORTED_STATES", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x8,0x001D] => ["OCF_LE_RECEIVER_TEST", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x8,0x001E] => ["OCF_LE_TRANSMITTER_TEST", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x8,0x001F] => ["OCF_LE_TEST_END", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0000] => ["OCF_HAL_GET_FW_BUILD_NUMBER", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x000C] => ["OCF_HAL_WRITE_CONFIG_DATA", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x000D] => ["OCF_HAL_READ_CONFIG_DATA", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x000F] => ["OCF_HAL_SET_TX_POWER_LEVEL", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0013] => ["OCF_HAL_DEVICE_STANDBY", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0014] => ["OCF_HAL_LE_TX_TEST_PACKET_NUMBER", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0015] => ["OCF_HAL_TONE_START", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0016] => ["OCF_HAL_TONE_STOP", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0017] => ["OCF_HAL_GET_LINK_STATUS", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0019] => ["OCF_HAL_GET_ANCHOR_PERIOD", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0020] => ["OCF_UPDATER_START", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0021] => ["OCF_UPDATER_REBOOT", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0022] => ["OCF_GET_UPDATER_VERSION", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0023] => ["OCF_GET_UPDATER_BUFSIZE", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0024] => ["OCF_UPDATER_ERASE_BLUE_FLAG", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0025] => ["OCF_UPDATER_RESET_BLUE_FLAG", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0026] => ["OCF_UPDATER_ERASE_SECTOR", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0027] => ["OCF_UPDATER_PROG_DATA_BLOCK", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0028] => ["OCF_UPDATER_READ_DATA_BLOCK", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0029] => ["OCF_UPDATER_CALC_CRC", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x002A] => ["OCF_UPDATER_HW_VERSION", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0081] => ["OCF_GAP_SET_NON_DISCOVERABLE", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0082] => ["OCF_GAP_SET_LIMITED_DISCOVERABLE", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0083] => ["OCF_GAP_SET_DISCOVERABLE", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0084] => ["OCF_GAP_SET_DIRECT_CONNECTABLE", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0085] => ["OCF_GAP_SET_IO_CAPABILITY", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0086] => ["OCF_GAP_SET_AUTH_REQUIREMENT", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0087] => ["OCF_GAP_SET_AUTHOR_REQUIREMENT", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0088] => ["OCF_GAP_PASSKEY_RESPONSE", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0089] => ["OCF_GAP_AUTHORIZATION_RESPONSE", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x008A] => ["OCF_GAP_INIT", :OCF_GENERIC, :Gap_Init_Rp],
          [0x3f,0x008B] => ["OCF_GAP_SET_NON_CONNECTABLE", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x008C] => ["OCF_GAP_SET_UNDIRECTED_CONNECTABLE", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x008D] => ["OCF_GAP_SLAVE_SECURITY_REQUEST", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x008E] => ["OCF_GAP_UPDATE_ADV_DATA", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x008F] => ["OCF_GAP_DELETE_AD_TYPE", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0090] => ["OCF_GAP_GET_SECURITY_LEVEL", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0091] => ["OCF_GAP_SET_EVT_MASK", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0092] => ["OCF_GAP_CONFIGURE_WHITELIST", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0093] => ["OCF_GAP_TERMINATE", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0094] => ["OCF_GAP_CLEAR_SECURITY_DB", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0095] => ["OCF_GAP_ALLOW_REBOND_DB", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0096] => ["OCF_GAP_START_LIMITED_DISCOVERY_PROC", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0097] => ["OCF_GAP_START_GENERAL_DISCOVERY_PROC", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0098] => ["OCF_GAP_START_NAME_DISCOVERY_PROC", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0099] => ["OCF_GAP_START_AUTO_CONN_ESTABLISH_PROC", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x009A] => ["OCF_GAP_START_GENERAL_CONN_ESTABLISH_PROC", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x009B] => ["OCF_GAP_START_SELECTIVE_CONN_ESTABLISH_PROC", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x009C] => ["OCF_GAP_CREATE_CONNECTION", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x009D] => ["OCF_GAP_TERMINATE_GAP_PROCEDURE", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x009E] => ["OCF_GAP_START_CONNECTION_UPDATE", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x009F] => ["OCF_GAP_SEND_PAIRING_REQUEST", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x00A0] => ["OCF_GAP_RESOLVE_PRIVATE_ADDRESS", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x00A1] => ["OCF_GAP_SET_BROADCAST_MODE", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x00A2] => ["OCF_GAP_START_OBSERVATION_PROC", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x00A3] => ["OCF_GAP_GET_BONDED_DEVICES", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x00A4] => ["OCF_GAP_IS_DEVICE_BONDED", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0101] => ["OCF_GATT_INIT", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0102] => ["OCF_GATT_ADD_SERV", :OCF_GATT_ADD_SERV, :Gatt_Add_Serv_Rp],
          [0x3f,0x0103] => ["OCF_GATT_INCLUDE_SERV", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0104] => ["OCF_GATT_ADD_CHAR", :OCF_GATT_ADD_CHAR, :Gatt_Add_Char_Rp],
          [0x3f,0x0105] => ["OCF_GATT_ADD_CHAR_DESC", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0106] => ["OCF_GATT_UPD_CHAR_VAL", :OCF_GATT_UPD_CHAR_VAL, :OCF_GENERIC_REPLY],
          [0x3f,0x0107] => ["OCF_GATT_DEL_CHAR", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0108] => ["OCF_GATT_DEL_SERV", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0109] => ["OCF_GATT_DEL_INC_SERV", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x010A] => ["OCF_GATT_SET_EVT_MASK", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x010B] => ["OCF_GATT_EXCHANGE_CONFIG", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x010C] => ["OCF_ATT_FIND_INFO_REQ", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x010D] => ["OCF_ATT_FIND_BY_TYPE_VALUE_REQ", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x010E] => ["OCF_ATT_READ_BY_TYPE_REQ", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x010F] => ["OCF_ATT_READ_BY_GROUP_TYPE_REQ", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0110] => ["OCF_ATT_PREPARE_WRITE_REQ", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0111] => ["OCF_ATT_EXECUTE_WRITE_REQ", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0X0112] => ["OCF_GATT_DISC_ALL_PRIM_SERVICES", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0113] => ["OCF_GATT_DISC_PRIM_SERVICE_BY_UUID", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0X0114] => ["OCF_GATT_FIND_INCLUDED_SERVICES", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0X0115] => ["OCF_GATT_DISC_ALL_CHARAC_OF_SERV", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0X0116] => ["OCF_GATT_DISC_CHARAC_BY_UUID", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0X0117] => ["OCF_GATT_DISC_ALL_CHARAC_DESCRIPTORS", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0118] => ["OCF_GATT_READ_CHARAC_VAL", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0119] => ["OCF_GATT_READ_USING_CHARAC_UUID", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x011A] => ["OCF_GATT_READ_LONG_CHARAC_VAL", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x011B] => ["OCF_GATT_READ_MULTIPLE_CHARAC_VAL", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x011C] => ["OCF_GATT_WRITE_CHAR_VALUE", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x011D] => ["OCF_GATT_WRITE_LONG_CHARAC_VAL", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x011E] => ["OCF_GATT_WRITE_CHARAC_RELIABLE", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x011F] => ["OCF_GATT_WRITE_LONG_CHARAC_DESC", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0120] => ["OCF_GATT_READ_LONG_CHARAC_DESC", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0121] => ["OCF_GATT_WRITE_CHAR_DESCRIPTOR", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0122] => ["OCF_GATT_READ_CHAR_DESCRIPTOR", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0123] => ["OCF_GATT_WRITE_WITHOUT_RESPONSE", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0124] => ["OCF_GATT_SIGNED_WRITE_WITHOUT_RESPONSE", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0125] => ["OCF_GATT_CONFIRM_INDICATION", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0126] => ["OCF_GATT_WRITE_RESPONSE", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0127] => ["OCF_GATT_ALLOW_READ", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0128] => ["OCF_GATT_SET_SECURITY_PERMISSION", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0129] => ["OCF_GATT_SET_DESC_VAL", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x012A] => ["OCF_GATT_READ_HANDLE_VALUE", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x012B] => ["OCF_GATT_READ_HANDLE_VALUE_OFFSET", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x012C] => ["OCF_GATT_UPD_CHAR_VAL_EXT", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0181] => ["OCF_L2CAP_CONN_PARAM_UPDATE_REQ", :OCF_GENERIC, :OCF_GENERIC_REPLY],
          [0x3f,0x0182] => ["OCF_L2CAP_CONN_PARAM_UPDATE_RESP", :OCF_GENERIC, :OCF_GENERIC_REPLY]
}

def OCF_GATT_UPD_CHAR_VAL
  a = $work[$idx+1] + 2
  b = $work[$idx+2] + 1
  i = $idx+1+a
  sh = ($work[i+1] << 8) | $work[i]
  i += 2
  ch = ($work[i+1] << 8) | $work[i]
  i += 2
  cvo = $work[i]
  i += 1
  cvl = $work[i]
  i += 1
  if cvl > b
    p "think"
    exit
  end
  ts = ($work[i+1] << 8) | $work[i]
  printf "ts %04x: servh %04x charh %04x cvo %x cvl %x\n", ts, sh, ch, cvo, cvl
  i += 2
  for j in 0..cvl-3 do
    printf "%02x ", $work[i+j]
  end
  printf "\n"
#  p "Here char_val", $idx

end

def OCF_GENERIC_REPLY
  if $pkt[2] != 4
    printf "Need a custom handler here\n"
    exit
  end
  printf "status %02x\n", $pkt[6]
end
def READ_LOCAL_VERSION_RP
  printf "status %02x\n", $pkt[6]
  printf "hci_version %02x\n", $pkt[7]
  printf "hci_revision %04x\n", ($pkt[9] << 8) | $pkt[8]
  printf "lmp_pal_version %02x\n", $pkt[10]
  printf "manufacturer name %04x\n", ($pkt[12] << 8) | $pkt[11]
  printf "lmp_pal_subversion %04x\n", ($pkt[13] << 8) | $pkt[13]
end
def Gap_Init_Rp
  printf "status %02x\n", $pkt[6]
  printf "service_handle %04x\n", ($pkt[8] << 8) | $pkt[7]
  printf "dev_name_char_handle %04x\n", ($pkt[10] << 8) | $pkt[9]
  printf "appearance_char_handle %04x\n", ($pkt[12] << 8) | $pkt[11]
end
def Gatt_Add_Serv_Rp
  printf "status %02x\n", $pkt[6]
  printf "handle %04x\n", ($pkt[8] << 8) | $pkt[7]
end

def Gatt_Add_Char_Rp
  printf "status %02x\n", $pkt[6]
  printf "handle %04x\n", ($pkt[8] << 8) | $pkt[7]
end
def EVT_CMD_COMPLETE_CODE
  cmd = ($pkt[5] << 8) | $pkt[4]
  ocf = cmd & 0x3ff
  ogf = (cmd >> 10) & 0x3f
  printf "[%02x,%03x]\n", ogf,ocf
  t = $tuple[[ogf,ocf]]
  f = t[2]
  if f
    send(f)
  end
end

def EVT_DISCONN_COMPLETE_CODE
  printf "disconnect\n"
end

def EVT_LE_META_EVENT
  printf "subevent %02x\n", $pkt[3]
  case ($pkt[3])
  when 2
    printf "N reports %d\n", $pkt[4]
    off = 4
#    rec = [
#      [:event_type, 1],
#      [:address_type, 1],
#      [:address, 6]]
    for i in 1 .. $pkt[4] do
      printf "event_type 0x%x address_type 0x%x\n", $pkt[i + off], $pkt[i + off + 1]
      off += 2
      for j in 0 .. 5 do
        printf "%02x%s", $pkt[i + off + j], (j == 5 ? "\n" : ":")
      end
      off += 6
      remainder = $pkt[i + off] # how many to collect
      off += 1
      curr = 0
      while curr < remainder do
        len = $pkt[i + off]
        off += 1
        curr += (len + 1)
        printf "%02x: ", len
        for j in 0 .. len-1 do
          printf "%02x%s", $pkt[i + j + off], (j == (len-1) ? "\n" : " ")
        end
        off += len
      end
      printf "RSSI %02x\n", $pkt[i + off]
    end
  end
end

def EVT_VENDOR
  ecode = ($pkt[4] << 8) | $pkt[3]
  printf "ecode %04x\n", ecode
  case (ecode)
  when 0x802
    printf "conn_handle %04x\n", ($pkt[6] << 8) | $pkt[5]
    printf "len %02x\n", $pkt[7]
    printf "id %02x\n", $pkt[8]
    printf "l2cap len %04x\n", ($pkt[10] << 8) | $pkt[9]
    printf "interval min %04x\n", ($pkt[12] << 8) | $pkt[11]
    printf "interval max %04x\n", ($pkt[14] << 8) | $pkt[13]
    printf "slave_latency %04x\n", ($pkt[16] << 8) | $pkt[15]
    printf "timeout_mult %04x\n", ($pkt[18] << 8) | $pkt[17]
  when 0xc01
    printf "conn_handle %04x\n", ($pkt[6] << 8) | $pkt[5]
    printf "attr_handle %04x\n", ($pkt[8] << 8) | $pkt[7]
    printf "data_length %04x\n", ($pkt[10] << 8) | $pkt[9]
    printf "offset %04x\n", ($pkt[12] << 8) | $pkt[11]
  when 0xc0f
    printf "conn_handle %04x\n", ($pkt[6] << 8) | $pkt[5]
    len = $pkt[7]
    printf "Len %02x\n", len
    printf "attr_handle %04x\n", ($pkt[9] << 8) | $pkt[8]
    if len > 3
      len -= 2
      for i in 0 .. len - 1 do
        printf "%02x ",$pkt[10 + i]
      end
      printf "\n"
    end
  when 0xc11
    printf "conn_handle %04x\n", ($pkt[6] << 8) | $pkt[5]
    printf "Len %02x\n", $pkt[7]
    printf "Req %02x\n", $pkt[8]
    printf "attr_handle %04x\n", ($pkt[10] << 8) | $pkt[9]
    printf "Error %02x\n", $pkt[11]
  end
end

$events = Hash.new
$events = {
  0x5 => ["EVT_DISCONN_COMPLETE_CODE", :EVT_DISCONN_COMPLETE_CODE],
  0xE => ["EVT_CMD_COMPLETE_CODE", :EVT_CMD_COMPLETE_CODE],
  0x3E => ["EVT_LE_META_EVENT", :EVT_LE_META_EVENT],
  0xFF => ["EVT_VENDOR", :EVT_VENDOR]}

def OCF_GENERIC
  a = $work[$idx+1] + 2
  b = $work[$idx+2] + 1
  i = $idx+1+a
end

def isr_parse
  l = $work[$idx+1]
  $pkt = $work[$idx+2 .. $idx+2 + l]
  pkt_type = $pkt[0]
  if pkt_type != 4
    print "BB w/o event"
    exit
  end
  evt = $pkt[1]
  evtlen = $pkt[2]
  printf "evt %02x evtlen %02x\n", evt, evtlen
  lu = $events[evt]
  if lu != nil
    f = lu[1]
    p lu[0]
    if f
      send(f)
    end
  end
end
def OCF_GATT_ADD_CHAR
  a = $work[$idx+1] + 2
  b = $work[$idx+2] + 1
  printf "service handle %04x\n", ($work[$idx+8] << 8) | $work[$idx+7]
  uuid_type = $work[$idx+9]
  printf "uuid type %02x\n", uuid_type
  case (uuid_type)
  when 1
       uuid_len = 2
  when 2
       uuid_len = 16
  else
    printf "Error %d\n", uuid_type
    exit
  end
  pos = 0
  for i in 0 .. uuid_len-1 do
    pos = $idx+10 + i
    printf "%02x ", $work[pos]
  end
  printf "\n"
  printf "charvaluelen %02x\n", $work[pos+1]
  printf "charproperties %02x\n", $work[pos+2]
  printf "secpermissions %02x\n", $work[pos+3]
  printf "gattevtmask %02x\n", $work[pos+4]
  printf "encrykeysize %02x\n", $work[pos+5]
  printf "isvariable %02x\n", $work[pos+6]
end

def OCF_GATT_ADD_SERV
  a = $work[$idx+1] + 2
  b = $work[$idx+2] + 1
  uuid_type = $work[$idx+7]
  printf "service_uuid_type %02x\n", $work[$idx+7]
  case (uuid_type)
  when 1
       uuid_len = 2
  when 2
       uuid_len = 16
  else
    printf "Error %d\n", uuid_type
    exit
  end
  pos = 0
  for i in 0 .. uuid_len-1 do
    pos = $idx+8 + i
    printf "%02x ", $work[pos]
  end
  printf "\n"
  printf "service_type %02x\n", $work[pos+1]
  printf "max_attr_records %02x\n", $work[pos+2]
end

ocf_tuple = Hash.new
ogf_tuple = {4 => "OGF_INFO_PARAM",
             8 => "OGF_LE_CTL",
            0x3f => "OGF_VENDOR_CMD"}


#p $work
done = false
while not done do
  case $work[$idx]
  when 0xcc
#    printf "CC %02x %02x\n", $work[$idx+1], $work[$idx+2]
    $idx += 1
  when 0xbb
    a = $work[$idx+1] + 2
    printf "ISR @%d %d\n", $idx, $work[$idx+1]
    isr_parse
    $idx += a
  when 0xaa
    a = $work[$idx+1] + 2
    b = $work[$idx+2] + 1
    if $work[$idx+3] != 1
      printf "Have a think, +3 != 1 @%d\n", $idx+3;
      exit
    end
    x = ($work[$idx+5] << 8) | $work[$idx+4]
    ocf = x & 0x3ff
    ogf = (x >> 10) & 0x3f
    sogf = ogf_tuple[ogf]
    t = $tuple[[ogf,ocf]]
    if not sogf
      printf "sogf not defined %x\n", ogf
      exit
    end
    if not t
      printf "s not defined [%x,%x]\n", ogf, ocf
      exit
    end
    s = t[0]
    f = t[1]
    plen = $work[$idx+6]
    printf "SENDCMD @%d %d %d ogf %x ocf %x %s %s plen %d\n", $idx, $work[$idx+1], $work[$idx+2], ogf, ocf, sogf, s, plen
    if f
      send(f)
    end

    $idx = $idx + (a + b)
  else
    p "Lost"
    done = true
  end
end
