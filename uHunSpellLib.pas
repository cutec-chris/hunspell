(* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1/GPL 2.0/LGPL 2.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * Copyright (C) 2006
 * Miha Vrhovnik (http://simail.sf.net, http://xcollect.sf.net)
 * All Rights Reserved.
 *
 * Contributor(s):
 * 
 *  
 * Alternatively, the contents of this file may be used under the terms of
 * either the GNU General Public License Version 2 or later (the "GPL"), or
 * the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
 * in which case the provisions of the GPL or the LGPL are applicable instead
 * of those above. If you wish to allow use of your version of this file only
 * under the terms of either the GPL or the LGPL, and not to allow others to
 * use your version of this file under the terms of the MPL, indicate your
 * decision by deleting the provisions above and replace them with the notice
 * and other provisions required by the GPL or the LGPL. If you do not delete
 * the provisions above, a recipient may use your version of this file under
 * the terms of any one of the MPL, the GPL or the LGPL.
 *
 * ***** END LICENSE BLOCK ***** **)
unit uHunSpellLib;

{$ifdef FPC}
{$mode DELPHI}
{$ENDIF}

interface
uses SysUtils, dynlibs;

var hunspell_initialize: function(aff_file: PAnsiChar; dict_file: PAnsiChar): Pointer; cdecl;
var hunspell_uninitialize: procedure(sspel: Pointer); cdecl;
var hunspell_spell: function(spell: Pointer; word: PAnsiChar): Boolean; cdecl;
var hunspell_suggest: function(spell: Pointer; word: PAnsiChar; var suggestions: PPAnsiChar): Integer; cdecl;
var hunspell_suggest_auto: function(spell: Pointer; word: PAnsiChar; var suggestions: PPAnsiChar): Integer; cdecl;
var hunspell_suggest_free: procedure(spell: Pointer; suggestions: PPAnsiChar; suggestLen: Integer); cdecl;
var hunspell_get_dic_encoding: function(spell: Pointer): PAnsiChar; cdecl;
var hunspell_put_word: function(spell: Pointer; word: PAnsiChar): Integer; cdecl;

var  LibsLoaded: Boolean = False;
var  DLLHandle: THandle;

function LoadLibHunspell(libraryName: String): Boolean;

implementation

function LoadLibHunspell(libraryName: String): Boolean;
begin
  if libraryName = '' then
    {$ifdef WINDOWS}
    libraryName := 'hunspelldll.dll';
    {$else}
    libraryName := 'libhunspell.so';
    {$endif}

  Result := LibsLoaded;
  if Result then //already loaded.
    exit;

  DLLHandle := LoadLibrary(PChar(libraryName));
  if DLLHandle <> 0 then begin
    Result := True; //assume everything ok unless..

    @hunspell_initialize := GetProcAddress(DLLHandle, 'hunspell_initialize');
    if not Assigned(@hunspell_initialize) then Result := False;
    @hunspell_uninitialize := GetProcAddress(DLLHandle, 'hunspell_uninitialize');
    if not Assigned(@hunspell_uninitialize) then Result := False;
    @hunspell_spell := GetProcAddress(DLLHandle, 'hunspell_spell');
    if not Assigned(@hunspell_spell) then Result := False;
    @hunspell_suggest := GetProcAddress(DLLHandle, 'hunspell_suggest');
    if not Assigned(@hunspell_suggest) then Result := False;
    @hunspell_suggest_auto := GetProcAddress(DLLHandle, 'hunspell_suggest_auto');
    if not Assigned(@hunspell_suggest_auto) then Result := False;
    @hunspell_suggest_free := GetProcAddress(DLLHandle, 'hunspell_suggest_free');
    if not Assigned(@hunspell_suggest_free) then Result := False;
    @hunspell_get_dic_encoding := GetProcAddress(DLLHandle, 'hunspell_get_dic_encoding');
    if not Assigned(@hunspell_get_dic_encoding) then Result := False;
    @hunspell_put_word := GetProcAddress(DLLHandle, 'hunspell_put_word');
    if not Assigned(@hunspell_put_word) then Result := False;
  end;
end;

initialization

finalization
  if DLLHandle <> 0 then
      FreeLibrary(DLLHandle);
end.
