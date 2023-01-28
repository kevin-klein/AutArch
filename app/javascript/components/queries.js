
export const GRAVES_QUERY = `
query($id: Int!) {
  bones {
    id
    name
  }
  periods {
    id
    name
  }
  cultures {
    id
    name
  }
  mtHaplogroups {
    id
    name
  }
  yHaplogroups {
    id
    name
  }
  skeleton(id: $id) {
    id
    skeletonId
    skeletonFigure {
      figure {
        id
        x1
        y1
        x2
        y2
        typeName
      }

      grave {
        id

        page {
          image {
            data
          }
        }
      }
    }
    genetics {
      id
      dataType
      endoContent
      boneId
      mtHaplogroupId
      yHaplogroupId
      refGen
    }
    location {
      id
      lat
      lon
      name
    }
    chronology {
      id
      contextFrom
      contextTo
      periodId
      c14Dates {
        id
        c14Type
        labId
        ageBp
        interval
        material
        calbc1SigmaMax
        calbc1SigmaMin
        calbc2SigmaMax
        calbc2SigmaMin
        dateNote
        calMethod
        ref14c
        boneId
      }
    }
    stableIsotopes {
      id
      isoId
      isoValue
      refIso
      isotope
      baseline
      boneId
    }
    anthropology {
      id
      sexMorph
      sexGen
      sexConsensus
      ageAsReported
      ageClass
      height
      pathologiesType
    }
    taxonomy {
      id
      cultureReference
      cultureNote
      cultureId
    }
  }
}
`;

export const CREATE_PERIOD_MUTATION = `mutation CreatePeriod($name: String!) {
createPeriod(name: $name) {
  period {
    id
    name
  }
}
}`;

export const DELETE_PERIOD_MUTATION = `mutation ($id: String!) {
deletePeriod(id: $id) { id }
}`;

export const CREATE_CULTURE_MUTATION = `mutation CreateCulture($name: String!) {
createCulture(name: $name) {
  culture {
    id
    name
  }
}
}`;

export const DELETE_CULTURE_MUTATION = `mutation DeleteCulture($id: String!) {
deleteCulture(id: $id) { id }
}`;

export const CREATE_MT_HAPLOGROUP = `mutation CreateMTHaplogroup($name: String!) {
createMtHaplogroup(name: $name) {
  mtHaplogroup {
    id
    name
  }
}
}`;

export const DELETE_MT_HAPLOGROUP = `mutation DeleteMtHaplogroup($id: String!) {
deleteMtHaplogroup(id: $id) { id }
}`;

export const CREATE_Y_HAPLOGROUP = `mutation CreateYHaplogroup($name: String!) {
createYHaplogroup(name: $name) {
  yHaplogroup {
    id
    name
  }
}
}`;

export const DELETE_Y_HAPLOGROUP = `mutation DeleteYHaplogroup($id: String!) {
deleteYHaplogroup(id: $id) { id }
}`;

export const GRAVE_EDITOR_QUERY = `query($id: Int!) {
  sites {
    id
    name
  }
  grave(id: $id) {
    id
    figures {
      id
      x1
      x2
      y1
      y2
      typeName

      skeletons {
        id
      }
    }

    page {
      id
      image {
        id
        width
        height
        data
      }
    }

    arrow {
      id
      angle
    }
  }
}`;

export const GRAVE_VIEW_QUERY = `query($id: Int!) {
  grave(id: $id) {
    id
    figures {
      id
      x1
      x2
      y1
      y2
      typeName
    }

    page {
      id
      image {
        id
        width
        height
        data
      }
    }
  }
}`;

export const UPDATE_SKELETON_MUTATION = `mutation($id: Int!, $skeleton: SkeletonInput!) {
  updateSkeleton(id: $id, skeleton: $skeleton) {
    id
  }
}`;

export const SKELETONS_FIGURES_LIST_QUERY = `
  query($offset: Int!, $limit: Int!) {
    count: skeletonFiguresCount
    skeletonFigures(offset: $offset, limit: $limit) {
      id

    }

    publications {
      id
      title
      author
    }
  }
`;

