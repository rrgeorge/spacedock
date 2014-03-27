// Generated code, any edits will be eventually lost.
package com.funnyhatsoftware.spacedock.data;

import java.util.ArrayList;
import java.util.Map;

public class SquadBase extends Base {
    int mAdditionalPoints;
    public int getAdditionalPoints() { return mAdditionalPoints; }
    public SquadBase setAdditionalPoints(int v) { mAdditionalPoints = v; return this;}
    String mName;
    public String getName() { return mName; }
    public SquadBase setName(String v) { mName = v; return this;}
    String mNotes;
    public String getNotes() { return mNotes; }
    public SquadBase setNotes(String v) { mNotes = v; return this;}
    String mUuid;
    public String getUuid() { return mUuid; }
    public SquadBase setUuid(String v) { mUuid = v; return this;}
    Resource mResource;
    public Resource getResource() { return mResource; }
    public SquadBase setResource(Resource v) { mResource = v; return this;}
    ArrayList<EquippedShip> mEquippedShips = new ArrayList<EquippedShip>();
    @SuppressWarnings("unchecked")
    public ArrayList<EquippedShip> getEquippedShips() { return (ArrayList<EquippedShip>)mEquippedShips.clone(); }
    @SuppressWarnings("unchecked")
    public SquadBase setEquippedShips(ArrayList<EquippedShip> v) { mEquippedShips = (ArrayList<EquippedShip>)v.clone(); return this;}

    public void update(Map<String,Object> data) {
        mAdditionalPoints = DataUtils.intValue((String)data.get("AdditionalPoints"));
        mName = DataUtils.stringValue((String)data.get("Name"));
        mNotes = DataUtils.stringValue((String)data.get("Notes"));
        mUuid = DataUtils.stringValue((String)data.get("Uuid"));
    }

}
