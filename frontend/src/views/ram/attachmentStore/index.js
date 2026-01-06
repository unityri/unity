// ** Redux Imports
import { createSlice, createAsyncThunk } from "@reduxjs/toolkit";

// ** Axios Imports
import instance from "../../../utility/AxiosConfig";

import { API_ENDPOINTS } from "utility/ApiEndPoints";

// import { initAttachmentItem } from "utility/reduxConstant";

async function getAttachmentListRequest(params) {
  return instance.get(`${API_ENDPOINTS.attachments.list}`, { params })
    .then((items) => items.data).catch((error) => error)
}

export const getAttachmentList = createAsyncThunk("appAttachments/getAttachmentList", async (params) => {
  try {
    const response = await getAttachmentListRequest(params);
    if (response && response.flag) {
      return {
        params,
        attachmentItems: response?.data || [],
        pagination: response?.pagination || null,
        actionFlag: "ATACHMNT_LST",
        success: "",
        error: ""
      }
    } else {
      return {
        params,
        attachmentItems: [],
        actionFlag: "",
        success: "",
        error: response.message
      }
    }
  } catch (error) {
    return {
      params,
      attachmentItems: [],
      actionFlag: "",
      success: "",
      error: error
    }
  }
})

async function getAttachmentRequest(params) {
  return instance.get(`${API_ENDPOINTS.attachments.get}/${params?.id}`)
    .then((items) => items.data).catch((error) => error)
}

export const getAttachment = createAsyncThunk("appAttachments/getAttachment", async (params) => {
  try {
    const response = await getAttachmentRequest(params);
    if (response && response.flag) {
      return {
        attachmentItem: response.data,
        actionFlag: "ATACHMNT_ITM",
        success: "",
        error: ""
      }
    } else {
      return {
        attachmentItem: null,
        actionFlag: "ATACHMNT_ITM_RR",
        success: "",
        error: ""
      }
    }
  } catch (error) {
    return {
      attachmentItem: null,
      actionFlag: "ATACHMNT_ITM_ERR",
      success: "",
      error: error
    }
  }
})

async function createAttachmentRequest(payload) {
  return instance.post(`${API_ENDPOINTS.attachments.create}`, payload)
    .then((items) => items.data).catch((error) => error)
}

export const createAttachment = createAsyncThunk("appAttachments/createAttachment", async (payload) => {
  try {
    const response = await createAttachmentRequest(payload);
    if (response && response.flag) {
      return {
        payload,
        attachmentItem: response.data || null,
        actionFlag: "ATACHMNT_CRTD_SCS",
        success: response?.message || "",
        error: ""
      }
    } else {
      return {
        payload,
        actionFlag: "ATACHMNT_CRTD_ERR",
        success: "",
        error: response.message
      }
    }
  } catch (error) {
    return {
      payload,
      actionFlag: "ATACHMNT_CRTD_ERR",
      success: "",
      error: error
    }
  }
})

async function updateAttachmentRequest(payload) {
  return instance.put(`${API_ENDPOINTS.attachments.update}`, payload)
    .then((items) => items.data).catch((error) => error);
}

export const updateAttachment = createAsyncThunk("appAttachments/updateAttachment", async (payload) => {
  try {
    const response = await updateAttachmentRequest(payload);
    if (response && response.flag) {
      return {
        payload,
        attachmentItem: response.data || null,
        actionFlag: "ATACHMNT_UPDT_SCS",
        success: response?.message || "",
        error: ""
      }
    } else {
      return {
        payload,
        actionFlag: "ATACHMNT_UPDT_ERR",
        success: "",
        error: response.message
      }
    }
  } catch (error) {
    return {
      payload,
      actionFlag: "ATACHMNT_UPDT_ERR",
      success: "",
      error: error
    }
  }
})

async function deleteAttachmentRequest(id) {
  return instance.delete(`${API_ENDPOINTS.attachments.delete}/${id}`)
    .then((items) => items.data).catch((error) => error)
}

export const deleteAttachment = createAsyncThunk("appAttachments/deleteAttachment", async (id) => {
  try {
    const response = await deleteAttachmentRequest(id);
    if (response && response.flag) {
      return {
        id,
        actionFlag: "ATACHMNT_DLT_SCS",
        success: response?.message || "",
        error: ""
      }
    } else {
      return {
        id,
        actionFlag: "ATACHMNT_DLT_ERR",
        success: "",
        error: response.message
      }
    }
  } catch (error) {
    return {
      id,
      actionFlag: "ATACHMNT_DLT_ERR",
      success: "",
      error: error
    }
  }
})

// Create a slice
const appAttachmentSlice = createSlice({
  name: "appAttachments",
  initialState: {
    attachmentItems: [],
    attachmentItem: null,
    pagination: null,
    actionFlag: "",
    loading: true,
    success: "",
    error: ""
  },
  reducers: {
    cleanAttachmentMessage: (state) => {
      state.actionFlag = "";
      state.success = "";
      state.error = "";
    }
  },
  extraReducers: (builder) => {
    builder
      .addCase(getAttachmentList.pending, (state) => {
        state.attachmentItems = [];
        state.loading = false;
        state.success = "";
        state.error = "";
      })
      .addCase(getAttachmentList.fulfilled, (state, action) => {
        state.attachmentItems = action.payload?.attachmentItems || [];
        state.pagination = action.payload?.pagination || null;
        state.loading = true;
        state.actionFlag = action.payload?.actionFlag || "";
        state.success = action.payload?.success;
        state.error = action.payload?.error;
      })
      .addCase(getAttachmentList.rejected, (state) => {
        state.loading = true;
        state.success = "";
        state.error = "";
      })
      .addCase(getAttachment.pending, (state) => {
        state.attachmentItem = null;
        state.loading = false;
        state.success = "";
        state.error = "";
      })
      .addCase(getAttachment.fulfilled, (state, action) => {
        state.attachmentItem = action.payload?.attachmentItem || null;
        state.loading = true;
        state.success = action.payload.success;
        state.error = action.payload.error;
      })
      .addCase(getAttachment.rejected, (state) => {
        state.loading = true;
        state.success = "";
        state.error = "";
      })
      .addCase(createAttachment.pending, (state) => {
        state.loading = false;
        state.success = "";
        state.error = "";
      })
      .addCase(createAttachment.fulfilled, (state, action) => {
        state.attachmentItem = action.payload?.attachmentItem || null;
        state.loading = true;
        state.actionFlag = action.payload?.actionFlag;
        state.success = action.payload?.success;
        state.error = action.payload?.error;
      })
      .addCase(createAttachment.rejected, (state) => {
        state.loading = true;
        state.success = "";
        state.error = "";
      })
      .addCase(updateAttachment.pending, (state) => {
        state.loading = false;
        state.success = "";
        state.error = "";
      })
      .addCase(updateAttachment.fulfilled, (state, action) => {
        state.attachmentItem = action.payload?.attachmentItem || null;
        state.loading = true;
        state.actionFlag = action.payload?.actionFlag;
        state.success = action.payload?.success;
        state.error = action.payload?.error;
      })
      .addCase(updateAttachment.rejected, (state) => {
        state.loading = true;
        state.success = "";
        state.error = "";
      })
      .addCase(deleteAttachment.pending, (state) => {
        state.loading = false;
        state.success = "";
        state.error = "";
      })
      .addCase(deleteAttachment.fulfilled, (state, action) => {
        state.loading = true;
        state.actionFlag = action.payload?.actionFlag;
        state.success = action.payload?.success;
        state.error = action.payload?.error;
      })
      .addCase(deleteAttachment.rejected, (state) => {
        state.loading = true;
        state.success = "";
        state.error = "";
      });
  },
});

export const { cleanAttachmentMessage } = appAttachmentSlice.actions;

export default appAttachmentSlice.reducer;
