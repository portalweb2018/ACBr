{******************************************************************************}
{ Projeto: Componentes ACBr                                                    }
{  Biblioteca multiplataforma de componentes Delphi para intera��o com equipa- }
{ mentos de Automa��o Comercial utilizados no Brasil                           }
{                                                                              }
{ Direitos Autorais Reservados (c) 2009   Isaque Pinheiro                      }
{                                                                              }
{ Colaboradores nesse arquivo:                                                 }
{                                                                              }
{  Voc� pode obter a �ltima vers�o desse arquivo na pagina do  Projeto ACBr    }
{ Componentes localizado em      http://www.sourceforge.net/projects/acbr      }
{                                                                              }
{  Esta biblioteca � software livre; voc� pode redistribu�-la e/ou modific�-la }
{ sob os termos da Licen�a P�blica Geral Menor do GNU conforme publicada pela  }
{ Free Software Foundation; tanto a vers�o 2.1 da Licen�a, ou (a seu crit�rio) }
{ qualquer vers�o posterior.                                                   }
{                                                                              }
{  Esta biblioteca � distribu�da na expectativa de que seja �til, por�m, SEM   }
{ NENHUMA GARANTIA; nem mesmo a garantia impl�cita de COMERCIABILIDADE OU      }
{ ADEQUA��O A UMA FINALIDADE ESPEC�FICA. Consulte a Licen�a P�blica Geral Menor}
{ do GNU para mais detalhes. (Arquivo LICEN�A.TXT ou LICENSE.TXT)              }
{                                                                              }
{  Voc� deve ter recebido uma c�pia da Licen�a P�blica Geral Menor do GNU junto}
{ com esta biblioteca; se n�o, escreva para a Free Software Foundation, Inc.,  }
{ no endere�o 59 Temple Street, Suite 330, Boston, MA 02111-1307 USA.          }
{ Voc� tamb�m pode obter uma copia da licen�a em:                              }
{ http://www.opensource.org/licenses/lgpl-license.php                          }
{                                                                              }
{ Daniel Sim�es de Almeida  -  daniel@djsystem.com.br  -  www.djsystem.com.br  }
{              Pra�a Anita Costa, 34 - Tatu� - SP - 18270-410                  }
{                                                                              }
{******************************************************************************}

{******************************************************************************
|* Historico
|*
|* 10/04/2009: Isaque Pinheiro
|*  - Cria��o e distribui��o da Primeira Versao
*******************************************************************************}

unit ACBrPAF_D_Class;

interface

uses SysUtils, Classes, DateUtils, ACBrTXTClass, ACBrPAFRegistros,
     ACBrPAF_D;

type
  /// TACBrPAF_D -
  TPAF_D = class(TACBrTXTClass)
  private
    FRegistroD1: TRegistroD1;       /// FRegistroD1
    FRegistroD2: TRegistroD2List;   /// Lista de FRegistroD2
    FRegistroD9: TRegistroD9;       /// FRegistroD9

    function WriteRegistroD3(RegD2: TRegistroD2): String;
    procedure CriaRegistros;
    procedure LiberaRegistros;
  public
    constructor Create; /// Create
    destructor Destroy; override; /// Destroy
    procedure LimpaRegistros;

    function WriteRegistroD1: String;
    function WriteRegistroD2: String;
    function WriteRegistroD9: String;

    property RegistroD1: TRegistroD1     read FRegistroD1 write FRegistroD1;
    property RegistroD2: TRegistroD2List read FRegistroD2 write FRegistroD2;
    property RegistroD9: TRegistroD9     read FRegistroD9 write FRegistroD9;
  end;

implementation

uses ACBrSpedUtils;

{ TPAF_D }

constructor TPAF_D.Create;
begin
   CriaRegistros;
end;

procedure TPAF_D.CriaRegistros;
begin
  FRegistroD1  := TRegistroD1.Create;
  FRegistroD2  := TRegistroD2List.Create;
  FRegistroD9  := TRegistroD9.Create;

  FRegistroD9.TOT_REG_D2 := 0;
  FRegistroD9.TOT_REG_D3 := 0;
  FRegistroD9.TOT_REG    := 0;
end;

destructor TPAF_D.Destroy;
begin
  LiberaRegistros;
  inherited;
end;

procedure TPAF_D.LiberaRegistros;
begin
  FRegistroD1.Free;
  FRegistroD2.Free;
  FRegistroD9.Free;
end;

procedure TPAF_D.LimpaRegistros;
begin
  /// Limpa os Registros
  LiberaRegistros;
  /// Recriar os Registros Limpos
  CriaRegistros;
end;

function TPAF_D.WriteRegistroD1: String;
begin
  FRegistroD9.TOT_REG_D2 := 0;
  FRegistroD9.TOT_REG_D3 := 0;
  FRegistroD9.TOT_REG    := 0;

   if Assigned(FRegistroD1) then
   begin
      with FRegistroD1 do
      begin
        Check(funChecaCNPJ(CNPJ), '(D1) ESTABELECIMENTO: O CNPJ "%s" digitado � inv�lido!', [CNPJ]);
        Check(funChecaIE(IE, UF), '(D1) ESTABELECIMENTO: A Inscri��o Estadual "%s" digitada � inv�lida!', [IE]);
        ///
        Result := LFill('D1') +
                  LFill(CNPJ, 14) +
                  RFill(IE, 14) +
                  RFill(IM, 14) +
                  RFill(RAZAOSOCIAL, 50) +
                  sLineBreak;
      end;
   end;
end;

function OrdenarD2(const ARegistro1, ARegistro2: Pointer): Integer;
var
  Dav1, Dav2: LongInt;
begin
  Dav1 := StrToIntDef(TRegistroD2(ARegistro1).NUM_DAV, 0);
  Dav2 := StrToIntDef(TRegistroD2(ARegistro2).NUM_DAV, 0);

  if Dav1 < Dav2 then
    Result := -1
  else
  if Dav1 > Dav2 then
    Result := 1
  else
    Result := 0;
end;

function TPAF_D.WriteRegistroD2: String;
var
intFor: integer;
strRegistroD2: String;
begin
  strRegistroD2 := '';

  if Assigned(FRegistroD2) then
  begin
    FRegistroD2.Sort(@OrdenarD2);

     for intFor := 0 to FRegistroD2.Count - 1 do
     begin
        with FRegistroD2.Items[intFor] do
        begin
          Check(funChecaCNPJ(FRegistroD1.CNPJ), '(D2) DAV EMITIDOS: O CNPJ "%s" digitado � inv�lido!', [FRegistroD1.CNPJ]);

          strRegistroD2 := strRegistroD2 + LFill('D2') +
                                           LFill(FRegistroD1.CNPJ, 14) +
                                           RFill(NUM_FAB, 20) +
                                           RFill(MF_ADICIONAL, 1) +
                                           RFill(TIPO_ECF, 7) +
                                           RFill(MARCA_ECF, 20) +
                                           RFill(MODELO_ECF, 20, ifThen(RegistroValido, ' ', '?')) +
                                           RFill(COO, 6, '0') +
                                           RFill(NUM_DAV, 13) +
                                           LFill(DT_DAV, 'yyyymmdd') +
                                           RFill(TIT_DAV, 30) +
                                           LFill(VLT_DAV, 8, 2) +
                                           LFill(COO_DFV, 6) +
                                           LFill(NUMERO_ECF, 3) +
                                           RFill(NOME_CLIENTE, 40) +
                                           LFill(CPF_CNPJ, 14) +

                                           sLineBreak;
        end;
        /// Registro FILHOS
        strRegistroD2 := strRegistroD2 +
                         WriteRegistroD3( FRegistroD2.Items[intFor] );
        ///
        FRegistroD9.TOT_REG_D2 := FRegistroD9.TOT_REG_D2 + 1;
        FRegistroD9.TOT_REG    := FRegistroD9.TOT_REG + 1;
     end;
     Result := strRegistroD2;
  end;
end;

function OrdenarD3(const ARegistro1, ARegistro2: Pointer): Integer;
var
  Item1, Item2: LongInt;
begin
  Item1 := TRegistroD3(ARegistro1).NUM_ITEM;
  Item2 := TRegistroD3(ARegistro2).NUM_ITEM;

  if Item1 < Item2 then
    Result := -1
  else
  if Item1 > Item2 then
    Result := 1
  else
    Result := 0;
end;

function TPAF_D.WriteRegistroD3(RegD2: TRegistroD2): String;
var
intFor: integer;
strRegistroD3: String;
begin
  strRegistroD3 := '';

  if Assigned(RegD2.RegistroD3) then
  begin
    RegD2.RegistroD3.Sort(@OrdenarD3);
     for intFor := 0 to RegD2.RegistroD3.Count - 1 do
     begin
        with RegD2.RegistroD3.Items[intFor] do
        begin
          ///
          strRegistroD3 := strRegistroD3 + LFill('D3') +
                                           LFill(RegD2.NUM_DAV, 13) +
                                           LFill(DT_INCLUSAO, 'yyyymmdd') +
                                           LFill(NUM_ITEM, 3, 0) +
                                           RFill(COD_ITEM, 14) +
                                           RFill(DESC_ITEM, 100) +
                                           LFill(QTDE_ITEM, 7, 3) +
                                           RFill(UNI_ITEM, 3) +
                                           LFill(VL_UNIT, 8, 2) +
                                           LFill(VL_DESCTO, 8, 2) +
                                           LFill(VL_ACRES, 8, 2) +
                                           LFill(VL_TOTAL, 14, 2) +
                                           RFill(COD_TCTP, 7) +
                                           LFill(IND_CANC) +
                                           sLineBreak;
        end;
        ///
        FRegistroD9.TOT_REG_D3 := FRegistroD9.TOT_REG_D3 + 1;
        FRegistroD9.TOT_REG    := FRegistroD9.TOT_REG + 1;
     end;
     Result := strRegistroD3;
  end;
end;

function TPAF_D.WriteRegistroD9: String;
begin
   if Assigned(FRegistroD9) then
   begin
      with FRegistroD9 do
      begin
        Check(funChecaCNPJ(FRegistroD1.CNPJ),             '(D9) TOTALIZA��O: O CNPJ "%s" digitado � inv�lido!', [FRegistroD1.CNPJ]);
        Check(funChecaIE(FRegistroD1.IE, FRegistroD1.UF), '(D9) TOTALIZA��O: A Inscri��o Estadual "%s" digitada � inv�lida!', [FRegistroD1.IE]);
        ///
        Result := LFill('D9') +
                  LFill(FRegistroD1.CNPJ, 14) +
                  LFill(FRegistroD1.IE, 14) +
                  LFill(TOT_REG_D2, 6, 0) +
                  LFill(TOT_REG_D3, 6, 0) +
                  sLineBreak;
      end;
   end;
end;

end.