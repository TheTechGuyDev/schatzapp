// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/flutter_flow/ff_builtin_enums.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart' hide RepeatMode;
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

List<CountryStruct> getCountriesList() {
  return [
    CountryStruct(
        name: 'Nigeria',
        dialCode: '234',
        isoCode: 'NG',
        flagUrl: 'https://flagcdn.com/w80/ng.png'),
    CountryStruct(
        name: 'Afghanistan',
        dialCode: '93',
        isoCode: 'AF',
        flagUrl: 'https://flagcdn.com/w80/af.png'),
    CountryStruct(
        name: 'Albania',
        dialCode: '355',
        isoCode: 'AL',
        flagUrl: 'https://flagcdn.com/w80/al.png'),
    CountryStruct(
        name: 'Algeria',
        dialCode: '213',
        isoCode: 'DZ',
        flagUrl: 'https://flagcdn.com/w80/dz.png'),
    CountryStruct(
        name: 'Andorra',
        dialCode: '376',
        isoCode: 'AD',
        flagUrl: 'https://flagcdn.com/w80/ad.png'),
    CountryStruct(
        name: 'Angola',
        dialCode: '244',
        isoCode: 'AO',
        flagUrl: 'https://flagcdn.com/w80/ao.png'),
    CountryStruct(
        name: 'Argentina',
        dialCode: '54',
        isoCode: 'AR',
        flagUrl: 'https://flagcdn.com/w80/ar.png'),
    CountryStruct(
        name: 'Armenia',
        dialCode: '374',
        isoCode: 'AM',
        flagUrl: 'https://flagcdn.com/w80/am.png'),
    CountryStruct(
        name: 'Australia',
        dialCode: '61',
        isoCode: 'AU',
        flagUrl: 'https://flagcdn.com/w80/au.png'),
    CountryStruct(
        name: 'Austria',
        dialCode: '43',
        isoCode: 'AT',
        flagUrl: 'https://flagcdn.com/w80/at.png'),
    CountryStruct(
        name: 'Azerbaijan',
        dialCode: '994',
        isoCode: 'AZ',
        flagUrl: 'https://flagcdn.com/w80/az.png'),
    CountryStruct(
        name: 'Bahamas',
        dialCode: '1242',
        isoCode: 'BS',
        flagUrl: 'https://flagcdn.com/w80/bs.png'),
    CountryStruct(
        name: 'Bahrain',
        dialCode: '973',
        isoCode: 'BH',
        flagUrl: 'https://flagcdn.com/w80/bh.png'),
    CountryStruct(
        name: 'Bangladesh',
        dialCode: '880',
        isoCode: 'BD',
        flagUrl: 'https://flagcdn.com/w80/bd.png'),
    CountryStruct(
        name: 'Barbados',
        dialCode: '1246',
        isoCode: 'BB',
        flagUrl: 'https://flagcdn.com/w80/bb.png'),
    CountryStruct(
        name: 'Belarus',
        dialCode: '375',
        isoCode: 'BY',
        flagUrl: 'https://flagcdn.com/w80/by.png'),
    CountryStruct(
        name: 'Belgium',
        dialCode: '32',
        isoCode: 'BE',
        flagUrl: 'https://flagcdn.com/w80/be.png'),
    CountryStruct(
        name: 'Belize',
        dialCode: '501',
        isoCode: 'BZ',
        flagUrl: 'https://flagcdn.com/w80/bz.png'),
    CountryStruct(
        name: 'Benin',
        dialCode: '229',
        isoCode: 'BJ',
        flagUrl: 'https://flagcdn.com/w80/bj.png'),
    CountryStruct(
        name: 'Bhutan',
        dialCode: '975',
        isoCode: 'BT',
        flagUrl: 'https://flagcdn.com/w80/bt.png'),
    CountryStruct(
        name: 'Bolivia',
        dialCode: '591',
        isoCode: 'BO',
        flagUrl: 'https://flagcdn.com/w80/bo.png'),
    CountryStruct(
        name: 'Bosnia and Herzegovina',
        dialCode: '387',
        isoCode: 'BA',
        flagUrl: 'https://flagcdn.com/w80/ba.png'),
    CountryStruct(
        name: 'Botswana',
        dialCode: '267',
        isoCode: 'BW',
        flagUrl: 'https://flagcdn.com/w80/bw.png'),
    CountryStruct(
        name: 'Brazil',
        dialCode: '55',
        isoCode: 'BR',
        flagUrl: 'https://flagcdn.com/w80/br.png'),
    CountryStruct(
        name: 'Brunei',
        dialCode: '673',
        isoCode: 'BN',
        flagUrl: 'https://flagcdn.com/w80/bn.png'),
    CountryStruct(
        name: 'Bulgaria',
        dialCode: '359',
        isoCode: 'BG',
        flagUrl: 'https://flagcdn.com/w80/bg.png'),
    CountryStruct(
        name: 'Burkina Faso',
        dialCode: '226',
        isoCode: 'BF',
        flagUrl: 'https://flagcdn.com/w80/bf.png'),
    CountryStruct(
        name: 'Burundi',
        dialCode: '257',
        isoCode: 'BI',
        flagUrl: 'https://flagcdn.com/w80/bi.png'),
    CountryStruct(
        name: 'Cambodia',
        dialCode: '855',
        isoCode: 'KH',
        flagUrl: 'https://flagcdn.com/w80/kh.png'),
    CountryStruct(
        name: 'Cameroon',
        dialCode: '237',
        isoCode: 'CM',
        flagUrl: 'https://flagcdn.com/w80/cm.png'),
    CountryStruct(
        name: 'Canada',
        dialCode: '1',
        isoCode: 'CA',
        flagUrl: 'https://flagcdn.com/w80/ca.png'),
    CountryStruct(
        name: 'Cape Verde',
        dialCode: '238',
        isoCode: 'CV',
        flagUrl: 'https://flagcdn.com/w80/cv.png'),
    CountryStruct(
        name: 'Central African Republic',
        dialCode: '236',
        isoCode: 'CF',
        flagUrl: 'https://flagcdn.com/w80/cf.png'),
    CountryStruct(
        name: 'Chad',
        dialCode: '235',
        isoCode: 'TD',
        flagUrl: 'https://flagcdn.com/w80/td.png'),
    CountryStruct(
        name: 'Chile',
        dialCode: '56',
        isoCode: 'CL',
        flagUrl: 'https://flagcdn.com/w80/cl.png'),
    CountryStruct(
        name: 'China',
        dialCode: '86',
        isoCode: 'CN',
        flagUrl: 'https://flagcdn.com/w80/cn.png'),
    CountryStruct(
        name: 'Colombia',
        dialCode: '57',
        isoCode: 'CO',
        flagUrl: 'https://flagcdn.com/w80/co.png'),
    CountryStruct(
        name: 'Comoros',
        dialCode: '269',
        isoCode: 'KM',
        flagUrl: 'https://flagcdn.com/w80/km.png'),
    CountryStruct(
        name: 'Congo (DRC)',
        dialCode: '243',
        isoCode: 'CD',
        flagUrl: 'https://flagcdn.com/w80/cd.png'),
    CountryStruct(
        name: 'Congo (Republic)',
        dialCode: '242',
        isoCode: 'CG',
        flagUrl: 'https://flagcdn.com/w80/cg.png'),
    CountryStruct(
        name: 'Costa Rica',
        dialCode: '506',
        isoCode: 'CR',
        flagUrl: 'https://flagcdn.com/w80/cr.png'),
    CountryStruct(
        name: 'Croatia',
        dialCode: '385',
        isoCode: 'HR',
        flagUrl: 'https://flagcdn.com/w80/hr.png'),
    CountryStruct(
        name: 'Cuba',
        dialCode: '53',
        isoCode: 'CU',
        flagUrl: 'https://flagcdn.com/w80/cu.png'),
    CountryStruct(
        name: 'Cyprus',
        dialCode: '357',
        isoCode: 'CY',
        flagUrl: 'https://flagcdn.com/w80/cy.png'),
    CountryStruct(
        name: 'Czech Republic',
        dialCode: '420',
        isoCode: 'CZ',
        flagUrl: 'https://flagcdn.com/w80/cz.png'),
    CountryStruct(
        name: 'Denmark',
        dialCode: '45',
        isoCode: 'DK',
        flagUrl: 'https://flagcdn.com/w80/dk.png'),
    CountryStruct(
        name: 'Djibouti',
        dialCode: '253',
        isoCode: 'DJ',
        flagUrl: 'https://flagcdn.com/w80/dj.png'),
    CountryStruct(
        name: 'Dominica',
        dialCode: '1767',
        isoCode: 'DM',
        flagUrl: 'https://flagcdn.com/w80/dm.png'),
    CountryStruct(
        name: 'Dominican Republic',
        dialCode: '1809',
        isoCode: 'DO',
        flagUrl: 'https://flagcdn.com/w80/do.png'),
    CountryStruct(
        name: 'Ecuador',
        dialCode: '593',
        isoCode: 'EC',
        flagUrl: 'https://flagcdn.com/w80/ec.png'),
    CountryStruct(
        name: 'Egypt',
        dialCode: '20',
        isoCode: 'EG',
        flagUrl: 'https://flagcdn.com/w80/eg.png'),
    CountryStruct(
        name: 'El Salvador',
        dialCode: '503',
        isoCode: 'SV',
        flagUrl: 'https://flagcdn.com/w80/sv.png'),
    CountryStruct(
        name: 'Equatorial Guinea',
        dialCode: '240',
        isoCode: 'GQ',
        flagUrl: 'https://flagcdn.com/w80/gq.png'),
    CountryStruct(
        name: 'Eritrea',
        dialCode: '291',
        isoCode: 'ER',
        flagUrl: 'https://flagcdn.com/w80/er.png'),
    CountryStruct(
        name: 'Estonia',
        dialCode: '372',
        isoCode: 'EE',
        flagUrl: 'https://flagcdn.com/w80/ee.png'),
    CountryStruct(
        name: 'Eswatini',
        dialCode: '268',
        isoCode: 'SZ',
        flagUrl: 'https://flagcdn.com/w80/sz.png'),
    CountryStruct(
        name: 'Ethiopia',
        dialCode: '251',
        isoCode: 'ET',
        flagUrl: 'https://flagcdn.com/w80/et.png'),
    CountryStruct(
        name: 'Fiji',
        dialCode: '679',
        isoCode: 'FJ',
        flagUrl: 'https://flagcdn.com/w80/fj.png'),
    CountryStruct(
        name: 'Finland',
        dialCode: '358',
        isoCode: 'FI',
        flagUrl: 'https://flagcdn.com/w80/fi.png'),
    CountryStruct(
        name: 'France',
        dialCode: '33',
        isoCode: 'FR',
        flagUrl: 'https://flagcdn.com/w80/fr.png'),
    CountryStruct(
        name: 'Gabon',
        dialCode: '241',
        isoCode: 'GA',
        flagUrl: 'https://flagcdn.com/w80/ga.png'),
    CountryStruct(
        name: 'Gambia',
        dialCode: '220',
        isoCode: 'GM',
        flagUrl: 'https://flagcdn.com/w80/gm.png'),
    CountryStruct(
        name: 'Georgia',
        dialCode: '995',
        isoCode: 'GE',
        flagUrl: 'https://flagcdn.com/w80/ge.png'),
    CountryStruct(
        name: 'Germany',
        dialCode: '49',
        isoCode: 'DE',
        flagUrl: 'https://flagcdn.com/w80/de.png'),
    CountryStruct(
        name: 'Ghana',
        dialCode: '233',
        isoCode: 'GH',
        flagUrl: 'https://flagcdn.com/w80/gh.png'),
    CountryStruct(
        name: 'Greece',
        dialCode: '30',
        isoCode: 'GR',
        flagUrl: 'https://flagcdn.com/w80/gr.png'),
    CountryStruct(
        name: 'Grenada',
        dialCode: '1473',
        isoCode: 'GD',
        flagUrl: 'https://flagcdn.com/w80/gd.png'),
    CountryStruct(
        name: 'Guatemala',
        dialCode: '502',
        isoCode: 'GT',
        flagUrl: 'https://flagcdn.com/w80/gt.png'),
    CountryStruct(
        name: 'Guinea',
        dialCode: '224',
        isoCode: 'GN',
        flagUrl: 'https://flagcdn.com/w80/gn.png'),
    CountryStruct(
        name: 'Guinea-Bissau',
        dialCode: '245',
        isoCode: 'GW',
        flagUrl: 'https://flagcdn.com/w80/gw.png'),
    CountryStruct(
        name: 'Guyana',
        dialCode: '592',
        isoCode: 'GY',
        flagUrl: 'https://flagcdn.com/w80/gy.png'),
    CountryStruct(
        name: 'Haiti',
        dialCode: '509',
        isoCode: 'HT',
        flagUrl: 'https://flagcdn.com/w80/ht.png'),
    CountryStruct(
        name: 'Honduras',
        dialCode: '504',
        isoCode: 'HN',
        flagUrl: 'https://flagcdn.com/w80/hn.png'),
    CountryStruct(
        name: 'Hong Kong',
        dialCode: '852',
        isoCode: 'HK',
        flagUrl: 'https://flagcdn.com/w80/hk.png'),
    CountryStruct(
        name: 'Hungary',
        dialCode: '36',
        isoCode: 'HU',
        flagUrl: 'https://flagcdn.com/w80/hu.png'),
    CountryStruct(
        name: 'Iceland',
        dialCode: '354',
        isoCode: 'IS',
        flagUrl: 'https://flagcdn.com/w80/is.png'),
    CountryStruct(
        name: 'India',
        dialCode: '91',
        isoCode: 'IN',
        flagUrl: 'https://flagcdn.com/w80/in.png'),
    CountryStruct(
        name: 'Indonesia',
        dialCode: '62',
        isoCode: 'ID',
        flagUrl: 'https://flagcdn.com/w80/id.png'),
    CountryStruct(
        name: 'Iran',
        dialCode: '98',
        isoCode: 'IR',
        flagUrl: 'https://flagcdn.com/w80/ir.png'),
    CountryStruct(
        name: 'Iraq',
        dialCode: '964',
        isoCode: 'IQ',
        flagUrl: 'https://flagcdn.com/w80/iq.png'),
    CountryStruct(
        name: 'Ireland',
        dialCode: '353',
        isoCode: 'IE',
        flagUrl: 'https://flagcdn.com/w80/ie.png'),
    CountryStruct(
        name: 'Israel',
        dialCode: '972',
        isoCode: 'IL',
        flagUrl: 'https://flagcdn.com/w80/il.png'),
    CountryStruct(
        name: 'Italy',
        dialCode: '39',
        isoCode: 'IT',
        flagUrl: 'https://flagcdn.com/w80/it.png'),
    CountryStruct(
        name: 'Ivory Coast',
        dialCode: '225',
        isoCode: 'CI',
        flagUrl: 'https://flagcdn.com/w80/ci.png'),
    CountryStruct(
        name: 'Jamaica',
        dialCode: '1876',
        isoCode: 'JM',
        flagUrl: 'https://flagcdn.com/w80/jm.png'),
    CountryStruct(
        name: 'Japan',
        dialCode: '81',
        isoCode: 'JP',
        flagUrl: 'https://flagcdn.com/w80/jp.png'),
    CountryStruct(
        name: 'Jordan',
        dialCode: '962',
        isoCode: 'JO',
        flagUrl: 'https://flagcdn.com/w80/jo.png'),
    CountryStruct(
        name: 'Kazakhstan',
        dialCode: '7',
        isoCode: 'KZ',
        flagUrl: 'https://flagcdn.com/w80/kz.png'),
    CountryStruct(
        name: 'Kenya',
        dialCode: '254',
        isoCode: 'KE',
        flagUrl: 'https://flagcdn.com/w80/ke.png'),
    CountryStruct(
        name: 'Kiribati',
        dialCode: '686',
        isoCode: 'KI',
        flagUrl: 'https://flagcdn.com/w80/ki.png'),
    CountryStruct(
        name: 'Kosovo',
        dialCode: '383',
        isoCode: 'XK',
        flagUrl: 'https://flagcdn.com/w80/xk.png'),
    CountryStruct(
        name: 'Kuwait',
        dialCode: '965',
        isoCode: 'KW',
        flagUrl: 'https://flagcdn.com/w80/kw.png'),
    CountryStruct(
        name: 'Kyrgyzstan',
        dialCode: '996',
        isoCode: 'KG',
        flagUrl: 'https://flagcdn.com/w80/kg.png'),
    CountryStruct(
        name: 'Laos',
        dialCode: '856',
        isoCode: 'LA',
        flagUrl: 'https://flagcdn.com/w80/la.png'),
    CountryStruct(
        name: 'Latvia',
        dialCode: '371',
        isoCode: 'LV',
        flagUrl: 'https://flagcdn.com/w80/lv.png'),
    CountryStruct(
        name: 'Lebanon',
        dialCode: '961',
        isoCode: 'LB',
        flagUrl: 'https://flagcdn.com/w80/lb.png'),
    CountryStruct(
        name: 'Lesotho',
        dialCode: '266',
        isoCode: 'LS',
        flagUrl: 'https://flagcdn.com/w80/ls.png'),
    CountryStruct(
        name: 'Liberia',
        dialCode: '231',
        isoCode: 'LR',
        flagUrl: 'https://flagcdn.com/w80/lr.png'),
    CountryStruct(
        name: 'Libya',
        dialCode: '218',
        isoCode: 'LY',
        flagUrl: 'https://flagcdn.com/w80/ly.png'),
    CountryStruct(
        name: 'Liechtenstein',
        dialCode: '423',
        isoCode: 'LI',
        flagUrl: 'https://flagcdn.com/w80/li.png'),
    CountryStruct(
        name: 'Lithuania',
        dialCode: '370',
        isoCode: 'LT',
        flagUrl: 'https://flagcdn.com/w80/lt.png'),
    CountryStruct(
        name: 'Luxembourg',
        dialCode: '352',
        isoCode: 'LU',
        flagUrl: 'https://flagcdn.com/w80/lu.png'),
    CountryStruct(
        name: 'Madagascar',
        dialCode: '261',
        isoCode: 'MG',
        flagUrl: 'https://flagcdn.com/w80/mg.png'),
    CountryStruct(
        name: 'Malawi',
        dialCode: '265',
        isoCode: 'MW',
        flagUrl: 'https://flagcdn.com/w80/mw.png'),
    CountryStruct(
        name: 'Malaysia',
        dialCode: '60',
        isoCode: 'MY',
        flagUrl: 'https://flagcdn.com/w80/my.png'),
    CountryStruct(
        name: 'Maldives',
        dialCode: '960',
        isoCode: 'MV',
        flagUrl: 'https://flagcdn.com/w80/mv.png'),
    CountryStruct(
        name: 'Mali',
        dialCode: '223',
        isoCode: 'ML',
        flagUrl: 'https://flagcdn.com/w80/ml.png'),
    CountryStruct(
        name: 'Malta',
        dialCode: '356',
        isoCode: 'MT',
        flagUrl: 'https://flagcdn.com/w80/mt.png'),
    CountryStruct(
        name: 'Mauritania',
        dialCode: '222',
        isoCode: 'MR',
        flagUrl: 'https://flagcdn.com/w80/mr.png'),
    CountryStruct(
        name: 'Mauritius',
        dialCode: '230',
        isoCode: 'MU',
        flagUrl: 'https://flagcdn.com/w80/mu.png'),
    CountryStruct(
        name: 'Mexico',
        dialCode: '52',
        isoCode: 'MX',
        flagUrl: 'https://flagcdn.com/w80/mx.png'),
    CountryStruct(
        name: 'Moldova',
        dialCode: '373',
        isoCode: 'MD',
        flagUrl: 'https://flagcdn.com/w80/md.png'),
    CountryStruct(
        name: 'Monaco',
        dialCode: '377',
        isoCode: 'MC',
        flagUrl: 'https://flagcdn.com/w80/mc.png'),
    CountryStruct(
        name: 'Mongolia',
        dialCode: '976',
        isoCode: 'MN',
        flagUrl: 'https://flagcdn.com/w80/mn.png'),
    CountryStruct(
        name: 'Montenegro',
        dialCode: '382',
        isoCode: 'ME',
        flagUrl: 'https://flagcdn.com/w80/me.png'),
    CountryStruct(
        name: 'Morocco',
        dialCode: '212',
        isoCode: 'MA',
        flagUrl: 'https://flagcdn.com/w80/ma.png'),
    CountryStruct(
        name: 'Mozambique',
        dialCode: '258',
        isoCode: 'MZ',
        flagUrl: 'https://flagcdn.com/w80/mz.png'),
    CountryStruct(
        name: 'Myanmar',
        dialCode: '95',
        isoCode: 'MM',
        flagUrl: 'https://flagcdn.com/w80/mm.png'),
    CountryStruct(
        name: 'Namibia',
        dialCode: '264',
        isoCode: 'NA',
        flagUrl: 'https://flagcdn.com/w80/na.png'),
    CountryStruct(
        name: 'Nauru',
        dialCode: '674',
        isoCode: 'NR',
        flagUrl: 'https://flagcdn.com/w80/nr.png'),
    CountryStruct(
        name: 'Nepal',
        dialCode: '977',
        isoCode: 'NP',
        flagUrl: 'https://flagcdn.com/w80/np.png'),
    CountryStruct(
        name: 'Netherlands',
        dialCode: '31',
        isoCode: 'NL',
        flagUrl: 'https://flagcdn.com/w80/nl.png'),
    CountryStruct(
        name: 'New Zealand',
        dialCode: '64',
        isoCode: 'NZ',
        flagUrl: 'https://flagcdn.com/w80/nz.png'),
    CountryStruct(
        name: 'Nicaragua',
        dialCode: '505',
        isoCode: 'NI',
        flagUrl: 'https://flagcdn.com/w80/ni.png'),
    CountryStruct(
        name: 'Niger',
        dialCode: '227',
        isoCode: 'NE',
        flagUrl: 'https://flagcdn.com/w80/ne.png'),
    CountryStruct(
        name: 'North Korea',
        dialCode: '850',
        isoCode: 'KP',
        flagUrl: 'https://flagcdn.com/w80/kp.png'),
    CountryStruct(
        name: 'North Macedonia',
        dialCode: '389',
        isoCode: 'MK',
        flagUrl: 'https://flagcdn.com/w80/mk.png'),
    CountryStruct(
        name: 'Norway',
        dialCode: '47',
        isoCode: 'NO',
        flagUrl: 'https://flagcdn.com/w80/no.png'),
    CountryStruct(
        name: 'Oman',
        dialCode: '968',
        isoCode: 'OM',
        flagUrl: 'https://flagcdn.com/w80/om.png'),
    CountryStruct(
        name: 'Pakistan',
        dialCode: '92',
        isoCode: 'PK',
        flagUrl: 'https://flagcdn.com/w80/pk.png'),
    CountryStruct(
        name: 'Palestine',
        dialCode: '970',
        isoCode: 'PS',
        flagUrl: 'https://flagcdn.com/w80/ps.png'),
    CountryStruct(
        name: 'Panama',
        dialCode: '507',
        isoCode: 'PA',
        flagUrl: 'https://flagcdn.com/w80/pa.png'),
    CountryStruct(
        name: 'Papua New Guinea',
        dialCode: '675',
        isoCode: 'PG',
        flagUrl: 'https://flagcdn.com/w80/pg.png'),
    CountryStruct(
        name: 'Paraguay',
        dialCode: '595',
        isoCode: 'PY',
        flagUrl: 'https://flagcdn.com/w80/py.png'),
    CountryStruct(
        name: 'Peru',
        dialCode: '51',
        isoCode: 'PE',
        flagUrl: 'https://flagcdn.com/w80/pe.png'),
    CountryStruct(
        name: 'Philippines',
        dialCode: '63',
        isoCode: 'PH',
        flagUrl: 'https://flagcdn.com/w80/ph.png'),
    CountryStruct(
        name: 'Poland',
        dialCode: '48',
        isoCode: 'PL',
        flagUrl: 'https://flagcdn.com/w80/pl.png'),
    CountryStruct(
        name: 'Portugal',
        dialCode: '351',
        isoCode: 'PT',
        flagUrl: 'https://flagcdn.com/w80/pt.png'),
    CountryStruct(
        name: 'Qatar',
        dialCode: '974',
        isoCode: 'QA',
        flagUrl: 'https://flagcdn.com/w80/qa.png'),
    CountryStruct(
        name: 'Romania',
        dialCode: '40',
        isoCode: 'RO',
        flagUrl: 'https://flagcdn.com/w80/ro.png'),
    CountryStruct(
        name: 'Russia',
        dialCode: '7',
        isoCode: 'RU',
        flagUrl: 'https://flagcdn.com/w80/ru.png'),
    CountryStruct(
        name: 'Rwanda',
        dialCode: '250',
        isoCode: 'RW',
        flagUrl: 'https://flagcdn.com/w80/rw.png'),
    CountryStruct(
        name: 'Saint Lucia',
        dialCode: '1758',
        isoCode: 'LC',
        flagUrl: 'https://flagcdn.com/w80/lc.png'),
    CountryStruct(
        name: 'Samoa',
        dialCode: '685',
        isoCode: 'WS',
        flagUrl: 'https://flagcdn.com/w80/ws.png'),
    CountryStruct(
        name: 'San Marino',
        dialCode: '378',
        isoCode: 'SM',
        flagUrl: 'https://flagcdn.com/w80/sm.png'),
    CountryStruct(
        name: 'Sao Tome and Principe',
        dialCode: '239',
        isoCode: 'ST',
        flagUrl: 'https://flagcdn.com/w80/st.png'),
    CountryStruct(
        name: 'Saudi Arabia',
        dialCode: '966',
        isoCode: 'SA',
        flagUrl: 'https://flagcdn.com/w80/sa.png'),
    CountryStruct(
        name: 'Senegal',
        dialCode: '221',
        isoCode: 'SN',
        flagUrl: 'https://flagcdn.com/w80/sn.png'),
    CountryStruct(
        name: 'Serbia',
        dialCode: '381',
        isoCode: 'RS',
        flagUrl: 'https://flagcdn.com/w80/rs.png'),
    CountryStruct(
        name: 'Seychelles',
        dialCode: '248',
        isoCode: 'SC',
        flagUrl: 'https://flagcdn.com/w80/sc.png'),
    CountryStruct(
        name: 'Sierra Leone',
        dialCode: '232',
        isoCode: 'SL',
        flagUrl: 'https://flagcdn.com/w80/sl.png'),
    CountryStruct(
        name: 'Singapore',
        dialCode: '65',
        isoCode: 'SG',
        flagUrl: 'https://flagcdn.com/w80/sg.png'),
    CountryStruct(
        name: 'Slovakia',
        dialCode: '421',
        isoCode: 'SK',
        flagUrl: 'https://flagcdn.com/w80/sk.png'),
    CountryStruct(
        name: 'Slovenia',
        dialCode: '386',
        isoCode: 'SI',
        flagUrl: 'https://flagcdn.com/w80/si.png'),
    CountryStruct(
        name: 'Solomon Islands',
        dialCode: '677',
        isoCode: 'SB',
        flagUrl: 'https://flagcdn.com/w80/sb.png'),
    CountryStruct(
        name: 'Somalia',
        dialCode: '252',
        isoCode: 'SO',
        flagUrl: 'https://flagcdn.com/w80/so.png'),
    CountryStruct(
        name: 'South Africa',
        dialCode: '27',
        isoCode: 'ZA',
        flagUrl: 'https://flagcdn.com/w80/za.png'),
    CountryStruct(
        name: 'South Korea',
        dialCode: '82',
        isoCode: 'KR',
        flagUrl: 'https://flagcdn.com/w80/kr.png'),
    CountryStruct(
        name: 'South Sudan',
        dialCode: '211',
        isoCode: 'SS',
        flagUrl: 'https://flagcdn.com/w80/ss.png'),
    CountryStruct(
        name: 'Spain',
        dialCode: '34',
        isoCode: 'ES',
        flagUrl: 'https://flagcdn.com/w80/es.png'),
    CountryStruct(
        name: 'Sri Lanka',
        dialCode: '94',
        isoCode: 'LK',
        flagUrl: 'https://flagcdn.com/w80/lk.png'),
    CountryStruct(
        name: 'Sudan',
        dialCode: '249',
        isoCode: 'SD',
        flagUrl: 'https://flagcdn.com/w80/sd.png'),
    CountryStruct(
        name: 'Suriname',
        dialCode: '597',
        isoCode: 'SR',
        flagUrl: 'https://flagcdn.com/w80/sr.png'),
    CountryStruct(
        name: 'Sweden',
        dialCode: '46',
        isoCode: 'SE',
        flagUrl: 'https://flagcdn.com/w80/se.png'),
    CountryStruct(
        name: 'Switzerland',
        dialCode: '41',
        isoCode: 'CH',
        flagUrl: 'https://flagcdn.com/w80/ch.png'),
    CountryStruct(
        name: 'Syria',
        dialCode: '963',
        isoCode: 'SY',
        flagUrl: 'https://flagcdn.com/w80/sy.png'),
    CountryStruct(
        name: 'Taiwan',
        dialCode: '886',
        isoCode: 'TW',
        flagUrl: 'https://flagcdn.com/w80/tw.png'),
    CountryStruct(
        name: 'Tajikistan',
        dialCode: '992',
        isoCode: 'TJ',
        flagUrl: 'https://flagcdn.com/w80/tj.png'),
    CountryStruct(
        name: 'Tanzania',
        dialCode: '255',
        isoCode: 'TZ',
        flagUrl: 'https://flagcdn.com/w80/tz.png'),
    CountryStruct(
        name: 'Thailand',
        dialCode: '66',
        isoCode: 'TH',
        flagUrl: 'https://flagcdn.com/w80/th.png'),
    CountryStruct(
        name: 'Togo',
        dialCode: '228',
        isoCode: 'TG',
        flagUrl: 'https://flagcdn.com/w80/tg.png'),
    CountryStruct(
        name: 'Tonga',
        dialCode: '676',
        isoCode: 'TO',
        flagUrl: 'https://flagcdn.com/w80/to.png'),
    CountryStruct(
        name: 'Trinidad and Tobago',
        dialCode: '1868',
        isoCode: 'TT',
        flagUrl: 'https://flagcdn.com/w80/tt.png'),
    CountryStruct(
        name: 'Tunisia',
        dialCode: '216',
        isoCode: 'TN',
        flagUrl: 'https://flagcdn.com/w80/tn.png'),
    CountryStruct(
        name: 'Turkey',
        dialCode: '90',
        isoCode: 'TR',
        flagUrl: 'https://flagcdn.com/w80/tr.png'),
    CountryStruct(
        name: 'Turkmenistan',
        dialCode: '993',
        isoCode: 'TM',
        flagUrl: 'https://flagcdn.com/w80/tm.png'),
    CountryStruct(
        name: 'Uganda',
        dialCode: '256',
        isoCode: 'UG',
        flagUrl: 'https://flagcdn.com/w80/ug.png'),
    CountryStruct(
        name: 'Ukraine',
        dialCode: '380',
        isoCode: 'UA',
        flagUrl: 'https://flagcdn.com/w80/ua.png'),
    CountryStruct(
        name: 'United Arab Emirates',
        dialCode: '971',
        isoCode: 'AE',
        flagUrl: 'https://flagcdn.com/w80/ae.png'),
    CountryStruct(
        name: 'United Kingdom',
        dialCode: '44',
        isoCode: 'GB',
        flagUrl: 'https://flagcdn.com/w80/gb.png'),
    CountryStruct(
        name: 'United States',
        dialCode: '1',
        isoCode: 'US',
        flagUrl: 'https://flagcdn.com/w80/us.png'),
    CountryStruct(
        name: 'Uruguay',
        dialCode: '598',
        isoCode: 'UY',
        flagUrl: 'https://flagcdn.com/w80/uy.png'),
    CountryStruct(
        name: 'Uzbekistan',
        dialCode: '998',
        isoCode: 'UZ',
        flagUrl: 'https://flagcdn.com/w80/uz.png'),
    CountryStruct(
        name: 'Vanuatu',
        dialCode: '678',
        isoCode: 'VU',
        flagUrl: 'https://flagcdn.com/w80/vu.png'),
    CountryStruct(
        name: 'Vatican City',
        dialCode: '379',
        isoCode: 'VA',
        flagUrl: 'https://flagcdn.com/w80/va.png'),
    CountryStruct(
        name: 'Venezuela',
        dialCode: '58',
        isoCode: 'VE',
        flagUrl: 'https://flagcdn.com/w80/ve.png'),
    CountryStruct(
        name: 'Vietnam',
        dialCode: '84',
        isoCode: 'VN',
        flagUrl: 'https://flagcdn.com/w80/vn.png'),
    CountryStruct(
        name: 'Yemen',
        dialCode: '967',
        isoCode: 'YE',
        flagUrl: 'https://flagcdn.com/w80/ye.png'),
    CountryStruct(
        name: 'Zambia',
        dialCode: '260',
        isoCode: 'ZM',
        flagUrl: 'https://flagcdn.com/w80/zm.png'),
    CountryStruct(
        name: 'Zimbabwe',
        dialCode: '263',
        isoCode: 'ZW',
        flagUrl: 'https://flagcdn.com/w80/zw.png'),
  ];
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the `</>` button on the right!
