// Copyright (c) 2018 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

package googlespreadsheet4;

import ballerina/io;
import ballerina/mime;
import ballerina/net.http;
import oauth2;

@Description {value : "Create a new spreadsheet"}
@Param {value : "spreadsheetName: Name of the spreadsheet"}
@Return{ value : "Spreadsheet: Spreadsheet object"}
@Return{ value : "SpreadsheetError: Spreadsheet error"}
public function <SpreadsheetConnector gsClient> createSpreadsheet (string spreadsheetName)
                                                              returns Spreadsheet | SpreadsheetError {
    endpoint oauth2:OAuth2Endpoint oauth2EP = gsClient.oauth2EP;
    http:Request request = {};
    Spreadsheet spreadsheetResponse = {};
    SpreadsheetError spreadsheetError = {};
    string createSpreadsheetPath = "/v4/spreadsheets";
    json spreadsheetJSONPayload = {"properties": {"title": spreadsheetName}};
    request.setJsonPayload(spreadsheetJSONPayload);
    try {
        http:Response response =? oauth2EP -> post(createSpreadsheetPath, request);
        int statusCode = response.statusCode;
        json spreadsheetJSONResponse =? response.getJsonPayload();
        if (statusCode == 200) {
            spreadsheetResponse = convertToSpreadsheet(spreadsheetJSONResponse);
        } else {
            spreadsheetError.errorMessage = spreadsheetJSONResponse.error.message.toString();
            spreadsheetError.statusCode = statusCode;
            return spreadsheetError;
        }
    } catch (http:HttpConnectorError err) {
        spreadsheetError.errorMessage = err.message;
        spreadsheetError.statusCode = err.statusCode;
        return spreadsheetError;
    } catch (mime:EntityError err) {
        spreadsheetError.errorMessage = err.message;
        return spreadsheetError;
    }
    return spreadsheetResponse;
}

@Description {value : "Get a spreadsheet by ID"}
@Param {value : "spreadsheetId: Id of the spreadsheet"}
@Return{ value : "Spreadsheet: Spreadsheet object"}
@Return{ value : "SpreadsheetError: Spreadsheet error"}
public function <SpreadsheetConnector gsClient> openSpreadsheetById (string spreadsheetId)
                                                                returns Spreadsheet | SpreadsheetError {
    endpoint oauth2:OAuth2Endpoint oauth2EP = gsClient.oauth2EP;
    http:Request request = {};
    Spreadsheet spreadsheetResponse = {};
    SpreadsheetError spreadsheetError = {};
    string getSpreadsheetPath = "/v4/spreadsheets/" + spreadsheetId;
    try {
        http:Response response =? oauth2EP -> get(getSpreadsheetPath, request);
        int statusCode = response.statusCode;
        json spreadsheetJSONResponse =? response.getJsonPayload();
        if (statusCode == 200) {
            spreadsheetResponse = convertToSpreadsheet(spreadsheetJSONResponse);
        } else {
            spreadsheetError.errorMessage = spreadsheetJSONResponse.error.message.toString();
            spreadsheetError.statusCode = statusCode;
            return spreadsheetError;
        }
    } catch (http:HttpConnectorError err) {
        spreadsheetError.errorMessage = err.message;
        spreadsheetError.statusCode = err.statusCode;
        return spreadsheetError;
    } catch (mime:EntityError err) {
        spreadsheetError.errorMessage = err.message;
        return spreadsheetError;
    }
    return spreadsheetResponse;
}

@Description {value : "Get spreadsheet values"}
@Param {value : "spreadsheetId: Id of the spreadsheet"}
@Param {value : "sheetName: Name of the sheet"}
@Param {value : "topLeftCell: Top right cell"}
@Param {value : "bottomRightCell: Bottom right cell"}
@Return{ value : "Sheet values"}
@Return{ value : "SpreadsheetError: Spreadsheet error"}
public function <SpreadsheetConnector gsClient> getSheetValues (string spreadsheetId, string sheetName,
                                string topLeftCell, string bottomRightCell) returns (string[][]) | SpreadsheetError {
    endpoint oauth2:OAuth2Endpoint oauth2EP = gsClient.oauth2EP;
    http:Request request = {};
    string[][] values = [];
    SpreadsheetError spreadsheetError = {};
    string a1Notation = sheetName + "!" + topLeftCell;
    if (bottomRightCell != "" && bottomRightCell != null) {
        a1Notation = a1Notation + ":" + bottomRightCell;
    }
    string getSheetValuesPath = "/v4/spreadsheets/" + spreadsheetId + "/values/" + a1Notation;
    try {
        http:Response response =? oauth2EP -> get(getSheetValuesPath, request);
        int statusCode = response.statusCode;
        json spreadsheetJSONResponse =? response.getJsonPayload();
        if (statusCode == 200) {
            if (spreadsheetJSONResponse.values != null) {
                int i = 0;
                foreach value in spreadsheetJSONResponse.values {
                    int j = 0;
                    string[] val = [];
                    foreach v in value {
                        val[j] = v.toString();
                        j = j + 1;
                    }
                    values[i] = val;
                    i = i + 1;
                }
            }
        } else {
            spreadsheetError.errorMessage = spreadsheetJSONResponse.error.message.toString();
            spreadsheetError.statusCode = statusCode;
            return spreadsheetError;
        }
    } catch (http:HttpConnectorError err) {
        spreadsheetError.errorMessage = err.message;
        spreadsheetError.statusCode = err.statusCode;
        return spreadsheetError;
    } catch (mime:EntityError err) {
        spreadsheetError.errorMessage = err.message;
        return spreadsheetError;
    }
    return values;
}

@Description {value : "Get column data"}
@Param {value : "spreadsheetId: Id of the spreadsheet"}
@Param {value : "sheetName: Name of the sheet"}
@Param {value : "column: Column name to retrieve the data"}
@Return{ value : "Column data"}
@Return{ value : "SpreadsheetError: Spreadsheet error"}
public function <SpreadsheetConnector gsClient> getColumnData (string spreadsheetId, string sheetName, string column)
                                                                returns (string[]) | SpreadsheetError {
    endpoint oauth2:OAuth2Endpoint oauth2EP = gsClient.oauth2EP;
    http:Request request = {};
    string[] values = [];
    SpreadsheetError spreadsheetError = {};
    string a1Notation = sheetName + "!" + column + ":" + column;
    string getSheetValuesPath = "/v4/spreadsheets/" + spreadsheetId + "/values/" + a1Notation;
    try {
        var response =? oauth2EP -> get(getSheetValuesPath, request);
        int statusCode = response.statusCode;
        json spreadsheetJSONResponse =? response.getJsonPayload();
        if (statusCode == 200) {
            if (spreadsheetJSONResponse.values != null) {
                int i = 0;
                foreach value in spreadsheetJSONResponse.values {
                    if (lengthof value > 0) {
                        values[i] = value[0].toString();
                    } else {
                        values[i] = "";
                    }
                    i = i + 1;
                }
            }
        } else {
            spreadsheetError.errorMessage = spreadsheetJSONResponse.error.message.toString();
            spreadsheetError.statusCode = statusCode;
            return spreadsheetError;
        }
    } catch (http:HttpConnectorError err) {
        spreadsheetError.errorMessage = err.message;
        spreadsheetError.statusCode = err.statusCode;
        return spreadsheetError;
    } catch (mime:EntityError err) {
        spreadsheetError.errorMessage = err.message;
        return spreadsheetError;
    }
    return values;
}

@Description {value : "Get row data"}
@Param {value : "spreadsheetId: Id of the spreadsheet"}
@Param {value : "sheetName: Name of the sheet"}
@Param {value : "row: Row to retrieve the data"}
@Return{ value : "Row data"}
@Return{ value : "SpreadsheetError: Spreadsheet error"}
public function <SpreadsheetConnector gsClient> getRowData (string spreadsheetId, string sheetName, int row)
                                                                returns (string[]) | SpreadsheetError {
    endpoint oauth2:OAuth2Endpoint oauth2EP = gsClient.oauth2EP;
    http:Request request = {};
    string[] values = [];
    SpreadsheetError spreadsheetError = {};
    string a1Notation = sheetName + "!" + row + ":" + row;
    string getSheetValuesPath = "/v4/spreadsheets/" + spreadsheetId + "/values/" + a1Notation;
    try {
        http:Response response =? oauth2EP -> get(getSheetValuesPath, request);
        int statusCode = response.statusCode;
        json spreadsheetJSONResponse =? response.getJsonPayload();
        if (statusCode == 200) {
            if (spreadsheetJSONResponse.values != null) {
                int i = 0;
                foreach value in spreadsheetJSONResponse.values[0] {
                    values[i] = value.toString();
                    i = i + 1;
                }
            }
        } else {
            spreadsheetError.errorMessage = spreadsheetJSONResponse.error.message.toString();
            spreadsheetError.statusCode = statusCode;
            return spreadsheetError;
        }
    } catch (http:HttpConnectorError err) {
        spreadsheetError.errorMessage = err.message;
        spreadsheetError.statusCode = err.statusCode;
        return spreadsheetError;
    } catch (mime:EntityError err) {
        spreadsheetError.errorMessage = err.message;
        return spreadsheetError;
    }
    return values;
}

@Description {value : "Get cell data"}
@Param {value : "spreadsheetId: Id of the spreadsheet"}
@Param {value : "sheetName: Name of the sheet"}
@Param {value : "column: Column name to retrieve the data"}
@Param {value : "row: Row to retrieve the data"}
@Return{ value : "Cell data"}
@Return{ value : "SpreadsheetError: Spreadsheet error"}
public function <SpreadsheetConnector gsClient> getCellData (string spreadsheetId, string sheetName, string column,
                                                                    int row) returns (string) | SpreadsheetError {
    endpoint oauth2:OAuth2Endpoint oauth2EP = gsClient.oauth2EP;
    http:Request request = {};
    string value = "";
    SpreadsheetError spreadsheetError = {};
    string a1Notation = sheetName + "!" + column + row;
    string getSheetValuesPath = "/v4/spreadsheets/" + spreadsheetId + "/values/" + a1Notation;
    try {
        http:Response response =? oauth2EP -> get(getSheetValuesPath, request);
        int statusCode = response.statusCode;
        json spreadsheetJSONResponse =? response.getJsonPayload();
        if (statusCode == 200) {
            if (spreadsheetJSONResponse.values != null) {
                value = spreadsheetJSONResponse.values[0][0].toString();
            }
        } else {
            spreadsheetError.errorMessage = spreadsheetJSONResponse.error.message.toString();
            spreadsheetError.statusCode = statusCode;
            return spreadsheetError;
        }
    } catch (http:HttpConnectorError err) {
        spreadsheetError.errorMessage = err.message;
        spreadsheetError.statusCode = err.statusCode;
        return spreadsheetError;
    } catch (mime:EntityError err) {
        spreadsheetError.errorMessage = err.message;
        return spreadsheetError;
    }
    return value;
}

@Description {value : "Set cell data"}
@Param {value : "spreadsheetId: Id of the spreadsheet"}
@Param {value : "sheetName: Name of the sheet"}
@Param {value : "column: Column name to retrieve the data"}
@Param {value : "row: Row to retrieve the data"}
@Param {value : "value: The value to be updated"}
@Return{ value : "Updated range"}
@Return{ value : "SpreadsheetError: Spreadsheet error"}
public function <SpreadsheetConnector gsClient> setCellData (string spreadsheetId, string sheetName,
                                         string column, int row, string value) returns Range | SpreadsheetError {
    endpoint oauth2:OAuth2Endpoint oauth2EP = gsClient.oauth2EP;
    http:Request request = {};
    Range rangeResponse = {};
    SpreadsheetError spreadsheetError = {};
    json jsonPayload = {"values" : [[value]]};
    string a1Notation = sheetName + "!" + column + row;
    string setValuePath = "/v4/spreadsheets/" + spreadsheetId + "/values/" + a1Notation + "?valueInputOption=RAW";
    request.setJsonPayload(jsonPayload);
    try {
        http:Response response =? oauth2EP -> put(setValuePath, request);
        int statusCode = response.statusCode;
        var spreadsheetJSONResponse =? response.getJsonPayload();
        if (statusCode == 200) {
            rangeResponse = convertToRange(spreadsheetJSONResponse);
        } else {
            spreadsheetError.errorMessage = spreadsheetJSONResponse.error.message.toString();
            spreadsheetError.statusCode = statusCode;
            return spreadsheetError;
        }
    } catch (http:HttpConnectorError err) {
        spreadsheetError.errorMessage = err.message;
        spreadsheetError.statusCode = err.statusCode;
        return spreadsheetError;
    } catch (mime:EntityError err) {
        spreadsheetError. errorMessage = err.message;
        return spreadsheetError;
    }
    return rangeResponse;
}

@Description {value : "Set sheet values"}
@Param {value : "spreadsheetId: Id of the spreadsheet"}
@Param {value : "sheetName: Name of the sheet"}
@Param {value : "topLeftCell: Top left cell"}
@Param {value : "bottomRightCell: Bottom right cell"}
@Param {value : "values: Values to be updated"}
@Return{ value : "Updated range"}
@Return{ value : "SpreadsheetError: Spreadsheet error"}
public function <SpreadsheetConnector gsClient> setSheetValues (string spreadsheetId, string sheetName,
                    string topLeftCell, string bottomRightCell, string[][] values) returns Range | SpreadsheetError {
    endpoint oauth2:OAuth2Endpoint oauth2EP = gsClient.oauth2EP;
    http:Request request = {};
    SpreadsheetError spreadsheetError = {};
    Range rangeResponse = {};
    string a1Notation = sheetName + "!" + topLeftCell + ":" + bottomRightCell;
    string setValuePath = "/v4/spreadsheets/" + spreadsheetId + "/values/" + a1Notation + "?valueInputOption=RAW";
    json[][] jsonValues = [];
    int i = 0;
    foreach value in values {
        int j = 0;
        json[] val = [];
        foreach v in value {
            val[j] = v;
            j = j + 1;
        }
        jsonValues[i] = val;
        i = i + 1;
    }
    json jsonPayload = {"values" : jsonValues};
    request.setJsonPayload(jsonPayload);
    try {
        http:Response response =? oauth2EP -> put(setValuePath, request);
        int statusCode = response.statusCode;
        json spreadsheetJSONResponse =? response.getJsonPayload();
        if (statusCode == 200) {
            rangeResponse = convertToRange(spreadsheetJSONResponse);

        } else {
            spreadsheetError.errorMessage = spreadsheetJSONResponse.error.message.toString();
            spreadsheetError.statusCode = statusCode;
            return spreadsheetError;
        }
    } catch (http:HttpConnectorError err) {
        spreadsheetError.errorMessage = err.message;
        spreadsheetError.statusCode = err.statusCode;
        return spreadsheetError;
    } catch (mime:EntityError err) {
        spreadsheetError. errorMessage = err.message;
        return spreadsheetError;
    }
    return rangeResponse;
}