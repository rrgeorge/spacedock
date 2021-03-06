package com.funnyhatsoftware.spacedock.holder;

import android.content.res.Resources;
import android.view.View;
import android.widget.TextView;

import com.funnyhatsoftware.spacedock.R;
import com.funnyhatsoftware.spacedock.data.SetItem;
import com.funnyhatsoftware.spacedock.fragment.DetailsFragment;
import com.funnyhatsoftware.spacedock.data.Captain;
import com.funnyhatsoftware.spacedock.data.Universe;

import java.util.List;

public class CaptainHolder extends SetItemHolder {
    public static final String TYPE_STRING = "Captain";
    static SetItemHolderFactory getFactory() {
        return new SetItemHolderFactory(Captain.class, TYPE_STRING) {
            @Override
            public SetItemHolder createHolder(View view) {
                return new CaptainHolder(view);
            }

            @Override
            public List<? extends SetItem> getItemsForFaction(String faction) {
                return Universe.getUniverse().getCaptainsForFaction(faction);
            }

            @Override
            public String getDetails(DetailsFragment.DetailDataBuilder builder, String id) {
                Captain captain = Universe.getUniverse().getCaptain(id);
                String faction = captain.getFaction();
                if (!"".equals(captain.getAdditionalFaction())) {
                    faction += ", " + captain.getAdditionalFaction();
                }
                builder.addString("Faction", faction);
                builder.addString("Type", captain.getUpType());
                builder.addInt("Skill", captain.getSkill());
                builder.addInt("Cost", captain.getCost());
                builder.addBoolean("Unique", captain.getUnique());
                builder.addInt("Talents", captain.getTalent());
                builder.addString("Set", captain.getSetName());
                builder.addString("Ability", captain.getAbility());
                return captain.getTitle();
            }
        };
    }

    final TextView mSkill;

    private CaptainHolder(View view) {
        super(view, R.layout.item_captain_values);
        mSkill = (TextView) view.findViewById(R.id.captainRowSkill);
    }

    @Override
    public void reinitializeStubViews(Resources res, SetItem item) {
        Captain captain = (Captain) item;
        mSkill.setText(Integer.toString(captain.getSkill()));
    }
}
